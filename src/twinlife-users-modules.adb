-----------------------------------------------------------------------
--  twinlife-users-modules -- Module users
--  Copyright (c) 2026 twinlife SA.
--  Written by Stephane.Carrez (Stephane.Carrez@twin.life)
--  SPDX-License-Identifier: Apache-2.0
-----------------------------------------------------------------------

with Security.OAuth.JWT.HS256;
with AWA.Users.Modules;
with AWA.Users.Services;
with AWA.Modules.Beans;
with AWA.Modules.Get;
with AWA.Services.Contexts;
with AWA.Users.Principals;
with ADO.SQL;
with ADO.Sessions;
with OpenAPI.Credentials.OAuth;
with Util.Log.Loggers;
with Twinlife.Users.Beans;
with Twinlife.Rest.Clients;
with Twinlife.Rest.Models;
package body Twinlife.Users.Modules is

   package ASC renames AWA.Services.Contexts;

   Log : constant Util.Log.Loggers.Logger := Util.Log.Loggers.Create ("Twinlife.Users.Module");

   package Register is new AWA.Modules.Beans (Module => User_Module,
                                              Module_Access => User_Module_Access);

   --  ------------------------------
   --  Initialize the users module.
   --  ------------------------------
   overriding
   procedure Initialize (Plugin : in out User_Module;
                         App    : in AWA.Modules.Application_Access;
                         Props  : in ASF.Applications.Config) is
   begin
      Log.Info ("Initializing the users module");

      --  Register here any bean class, servlet, filter.
      Register.Register (Plugin => Plugin,
                         Name   => "Twinlife.Users.Beans.Users_Bean",
                         Handler => Twinlife.Users.Beans.Create_User_Bean'Access);

      AWA.Modules.Module (Plugin).Initialize (App, Props);

      --  Add here the creation of manager instances.
   end Initialize;

   --  ------------------------------
   --  Configures the module after its initialization and after having read its XML configuration.
   --  ------------------------------
   overriding
   procedure Configure (Plugin : in out User_Module;
                        Props  : in ASF.Applications.Config) is
      pragma Unreferenced (Props);
   begin
      Plugin.Dev.Server := Plugin.Get_Config ("jwt.mytwinlife.url");
      Plugin.Dev.Secret := Plugin.Get_Config ("jwt.mytwinlife.secret");
      Plugin.Dev.Key_Id := Plugin.Get_Config ("jwt.mytwinlife.kid");
      Plugin.Dev.Issuer := Plugin.Get_Config ("jwt.mytwinlife.iss");
      Plugin.Dev.Subject := Plugin.Get_Config ("jwt.mytwinlife.subject");

      Plugin.Twinme.Server := Plugin.Get_Config ("jwt.twinme.url");
      Plugin.Twinme.Secret := Plugin.Get_Config ("jwt.twinme.secret");
      Plugin.Twinme.Key_Id := Plugin.Get_Config ("jwt.twinme.kid");
      Plugin.Twinme.Issuer := Plugin.Get_Config ("jwt.twinme.iss");
      Plugin.Twinme.Subject := Plugin.Get_Config ("jwt.twinme.subject");

      Plugin.Skred.Server := Plugin.Get_Config ("jwt.skred.url");
      Plugin.Skred.Secret := Plugin.Get_Config ("jwt.skred.secret");
      Plugin.Skred.Key_Id := Plugin.Get_Config ("jwt.skred.kid");
      Plugin.Skred.Issuer := Plugin.Get_Config ("jwt.skred.iss");
      Plugin.Skred.Subject := Plugin.Get_Config ("jwt.skred.subject");
   end Configure;

   --  ------------------------------
   --  Get the users module.
   --  ------------------------------
   function Get_User_Module return User_Module_Access is
      function Get is new AWA.Modules.Get (User_Module, User_Module_Access, NAME);
   begin
      return Get;
   end Get_User_Module;

   procedure Register_User (Plugin    : in out User_Module;
                            Mini_Code : in UString;
                            User      : in out AWA.Users.Models.User_Ref;
                            Session   : in out AWA.Users.Models.Session_Ref) is
      procedure Find_User (Config : in JWT_Info;
                           Found  : out Boolean);

      Twincode : Twinlife.Rest.Models.Twincode_Type;

      procedure Find_User (Config : in JWT_Info;
                           Found  : out Boolean) is
         Client   : Twinlife.Rest.Clients.Client_Type;
         Token    : Security.OAuth.JWT.Token;
         Cred     : aliased OpenAPI.Credentials.OAuth.OAuth2_Credential_Type;
      begin
         if Length (Config.Server) = 0 then
            Found := False;
            return;
         end if;
         Security.OAuth.JWT.Set_Key_ID (Token, To_String (Config.Key_Id));
         Security.OAuth.JWT.Set_Issuer (Token, To_String (Config.Issuer));
         Security.OAuth.JWT.Set_Subject (Token, To_String (Config.Subject));
         Security.OAuth.JWT.Set_Validity (Token, 3600.0, True);
         Cred.Bearer_Token (Security.OAuth.JWT.HS256.Sign (Token, To_String (Config.Secret)));
         Client.Set_Server (Config.Server);
         Client.Set_Credentials (Cred'Unchecked_Access);
         Client.Get_Mini_Code (Mini_Code, Twincode);
         Client.Set_Timeout (Duration (Plugin.Get_Config ("timeout", 20)));
         Client.Get_Mini_Code (Mini_Code, Twincode);
         Found := True;
         Log.Info ("Mini-code {0} identified as {1}", To_String (Mini_Code),
                   To_String (Twincode.Name));

      exception
         when E : others =>
            Found := False;
            Log.Info ("Mini-code {0} not found on {1}", To_String (Mini_Code),
                      To_String (Config.Server));
            Log.Error ("Exception", E);
      end Find_User;

      Found : Boolean;
   begin
      Log.Info ("Register user with mini-code {0}", Mini_Code);

      Find_User (Plugin.Twinme, Found);
      if not Found then
         Find_User (Plugin.Skred, Found);
      end if;
      if not Found then
         Find_User (Plugin.Dev, Found);
      end if;
      if not Found or else Twincode.Public_Key.Is_Null then
         raise AWA.Users.Services.Not_Found;
      end if;

      Plugin.Create_User (Twincode.Public_Key.Value, Twincode.Name, "", User, Session);
      Log.Info ("Principal created");
   end Register_User;

   procedure Create_User (Plugin    : in out User_Module;
                          User_Id   : in UString;
                          Pseudo    : in UString;
                          Ip_Addr   : in String;
                          User      : in out AWA.Users.Models.User_Ref;
                          Session   : in out AWA.Users.Models.Session_Ref) is
      use AWA.Users.Models;
      use ADO.Sessions;

      Ctx        : constant ASC.Service_Context_Access := ASC.Current;
      DB         : Master_Session := ASC.Get_Master_Session (Ctx);
      Query      : ADO.SQL.Query;
      Found_Auth : Boolean;
      Found_User : Boolean;
      Email      : Email_Ref;
      Auth       : Authenticate_Ref;
      User_Service : constant AWA.Users.Services.User_Service_Access
        := AWA.Users.Modules.Get_User_Manager;
      Principal  : AWA.Users.Principals.Principal_Access;
   begin
      Log.Info ("Create user {0} - {1}", To_String (User_Id), To_String (Pseudo));

      Ctx.Start;
      Query.Set_Filter ("o.method=2 AND o.ident=:user_id");
      Query.Bind_Param ("user_id", User_Id);
      Auth.Find (DB, Query, Found_Auth);

      Query.Clear;
      Query.Set_Join ("INNER JOIN awa_authenticate a ON a.user_id = o.id");
      Query.Set_Filter ("a.method=2 AND a.ident=:user_id");
      Query.Bind_Param ("user_id", User_Id);
      User.Find (DB, Query, Found_User);

      if Found_Auth then
         User := User_Ref (Auth.Get_User);
         Email := Email_Ref (User.Get_Email);
         Found_User := True;
      end if;

      if not Found_User then
         Email.Set_User_Id (0);
         Email.Set_Status (AWA.Users.Models.HARD_BOUNCE);
         Email.Save (DB);

         User.Set_Email (Email);
         User.Set_Status (AWA.Users.Models.USER_ENABLED);
         User.Set_Name (Pseudo);
         User.Save (DB);

         Email.Set_User_Id (User.Get_Id);
         Email.Save (DB);
      end if;

      if not Found_Auth then
         Auth.Set_Email (Email);
         Auth.Set_User (User);
         Auth.Set_Ident (User_Id);
         Auth.Set_Method (AWA.Users.Models.AUTH_APPLICATION);
         Auth.Save (DB);
      end if;

      User_Service.Create_Session (DB, Session, User, Auth, Ip_Addr, Principal);
      Ctx.Commit;
   end Create_User;

end Twinlife.Users.Modules;

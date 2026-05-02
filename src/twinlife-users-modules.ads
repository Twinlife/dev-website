-----------------------------------------------------------------------
--  twinlife-users-modules -- Module users
--  Copyright (c) 2026 twinlife SA.
--  Written by Stephane.Carrez (Stephane.Carrez@twin.life)
--  SPDX-License-Identifier: Apache-2.0
-----------------------------------------------------------------------
with ASF.Applications;
with AWA.Modules;
with AWA.Users.Models;
package Twinlife.Users.Modules is

   --  The name under which the module is registered.
   NAME : constant String := "twusers";

   --  ------------------------------
   --  Module users
   --  ------------------------------
   type User_Module is new AWA.Modules.Module with private;
   type User_Module_Access is access all User_Module'Class;

   --  Initialize the users module.
   overriding
   procedure Initialize (Plugin : in out User_Module;
                         App    : in AWA.Modules.Application_Access;
                         Props  : in ASF.Applications.Config);

   --  Configures the module after its initialization and after having read its XML configuration.
   overriding
   procedure Configure (Plugin : in out User_Module;
                        Props  : in ASF.Applications.Config);

   procedure Register_User (Plugin    : in out User_Module;
                            Mini_Code : in UString;
                            User      : in out AWA.Users.Models.User_Ref;
                            Session   : in out AWA.Users.Models.Session_Ref);

   --  Get the users module.
   function Get_User_Module return User_Module_Access;

private

   type JWT_Info is record
      Server  : UString;
      Key_Id  : UString;
      Issuer  : UString;
      Subject : UString;
      Secret  : UString;
   end record;

   type User_Module is new AWA.Modules.Module with record
      Twinme : JWT_Info;
      Skred  : JWT_Info;
      Dev    : JWT_Info;
   end record;

   procedure Create_User (Plugin    : in out User_Module;
                          User_Id   : in UString;
                          Pseudo    : in UString;
                          Ip_Addr   : in String;
                          User      : in out AWA.Users.Models.User_Ref;
                          Session   : in out AWA.Users.Models.Session_Ref);

end Twinlife.Users.Modules;

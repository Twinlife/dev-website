-----------------------------------------------------------------------
--  twinlife-versions -- Information about twinme & Skred versions
--  Copyright (c) 2026 twinlife SA.
--  Written by Stephane.Carrez (Stephane.Carrez@twin.life)
--  SPDX-License-Identifier: Apache-2.0
-----------------------------------------------------------------------
with Util.Log.Loggers;
with Util.Strings.Vectors;
with AWA.Events.Action_Method;
with Twinlife.Rest.Clients;
package body Twinlife.Versions is

   use type Ada.Strings.Unbounded.Unbounded_String;

   Log     : constant Util.Log.Loggers.Logger := Util.Log.Loggers.Create ("Twinlife.Versions");

   Data : aliased Versions_Type;

   package Refresh_Binding is
     new AWA.Events.Action_Method.Bind (Bean   => Version_Bean,
                                        Method => Refresh,
                                        Name   => "refresh");

   Version_Bean_Binding : aliased constant Util.Beans.Methods.Method_Binding_Array
     := (1 => Refresh_Binding.Proxy'Access);

   function Create_Version_Bean return Util.Beans.Basic.Readonly_Bean_Access is
      V : constant Version_Bean_Access := new Version_Bean;
   begin
      return V.all'Access;
   end Create_Version_Bean;

   protected body Version_Data is

      procedure Get_Version (Version : in out Version_Info) is
      begin
         for V of Versions loop
            if V.Name = Version.Name then
               Version := V;
               return;
            end if;
         end loop;
         Versions.Append (Version);
      end Get_Version;

      procedure Set_Version (Version : in Version_Info) is
      begin
         for V of Versions loop
            if V.Name = Version.Name then
               V := Version;
               V.Timestamp := Ada.Calendar.Clock;
               return;
            end if;
         end loop;
         Versions.Append (Version);
      end Set_Version;

   end Version_Data;

   procedure Refresh (Bean  : in out Version_Bean;
                      Event : in AWA.Events.Module_Event'Class) is
      Client : Twinlife.Rest.Clients.Client_Type;
   begin
      Log.Info ("Get application version from {0}", Bean.Info.Uri);

      Client.Set_Server (Bean.Info.Uri);
      Client.Get_Version (Bean.Info.Name, Bean.Info.Android);
      Client.Get_Version (Bean.Info.Name_iOS, Bean.Info.IOS);
      Data.Versions.Set_Version (Bean.Info);

      Log.Info ("Application version from {0}", Bean.Info.Android.Version);
   end Refresh;

   --  ------------------------------
   --  This bean provides some methods that can be used in a Method_Expression
   --  ------------------------------
   overriding
   function Get_Method_Bindings (From : in Version_Bean)
                                 return Util.Beans.Methods.Method_Binding_Array_Access is
      pragma Unreferenced (From);
   begin
      return Version_Bean_Binding'Access;
   end Get_Method_Bindings;

   --  Get the value identified by the name.
   overriding
   function Get_Value (From : Version_Bean;
                       Name : String) return UBO.Object is
   begin
      if Name = "version" then
         return UBO.To_Object (From.Info.Android.Version);
      elsif Name = "minSdk" and then not From.Info.Android.Min_Sdk.Is_Null then
         return UBO.To_Object (From.Info.Android.Min_Sdk.Value);
      elsif Name = "size" and then not From.Info.Android.Size.Is_Null then
         return UBO.To_Object (From.Info.Android.Size.Value);
      elsif Name = "sha256sum" and then not From.Info.Android.Sha_256sum.Is_Null then
         return UBO.To_Object (From.Info.Android.Sha_256sum.Value);
      elsif Name = "changes" then
         return UBO.To_Object (From.Changes'Unrestricted_Access, UBO.STATIC);
      else
         return UBO.Null_Object;
      end if;
   end Get_Value;

   --  Set the value identified by the name.
   overriding
   procedure Set_Value (From  : in out Version_Bean;
                        Name  : in String;
                        Value : in Util.Beans.Objects.Object) is
   begin
      if Name = "name_ios" then
         From.Info.Name_iOS := UBO.To_Unbounded_String (Value);
      elsif Name = "uri" then
         From.Info.Uri := UBO.To_Unbounded_String (Value);
      elsif Name = "name" then
         From.Info.Name := UBO.To_Unbounded_String (Value);
         Data.Versions.Get_Version (From.Info);
         for S of From.Info.Android.Changes.Major loop
            From.Changes.List.Append (To_String (S));
         end loop;
      end if;
   end Set_Value;

end Twinlife.Versions;

-----------------------------------------------------------------------
--  twinlife-users-beans -- Beans for module users
--  Copyright (c) 2026 twinlife SA.
--  Written by Stephane.Carrez (Stephane.Carrez@twin.life)
--  SPDX-License-Identifier: Apache-2.0
-----------------------------------------------------------------------

with ASF.Events.Faces.Actions;
package body Twinlife.Users.Beans is

   --  ------------------------------
   --  Example of action method.
   --  ------------------------------
   procedure Action (Bean    : in out User_Bean;
                     Outcome : in out Ada.Strings.Unbounded.Unbounded_String) is
   begin
      null;
   end Action;

   package Action_Binding is
     new ASF.Events.Faces.Actions.Action_Method.Bind (Bean   => User_Bean,
                                                      Method => Action,
                                                      Name   => "action");

   User_Bean_Binding : aliased constant Util.Beans.Methods.Method_Binding_Array
     := (Action_Binding.Proxy'Access, null);

   --  ------------------------------
   --  Get the value identified by the name.
   --  ------------------------------
   overriding
   function Get_Value (From : in User_Bean;
                       Name : in String) return Util.Beans.Objects.Object is
   begin
      if Name = "count" then
         return Util.Beans.Objects.To_Object (From.Count);
      else
         return Util.Beans.Objects.Null_Object;
      end if;
   end Get_Value;

   --  ------------------------------
   --  Set the value identified by the name.
   --  ------------------------------
   overriding
   procedure Set_Value (From  : in out User_Bean;
                        Name  : in String;
                        Value : in Util.Beans.Objects.Object) is
   begin
      if Name = "count" then
         From.Count := Util.Beans.Objects.To_Integer (Value);
      end if;
   end Set_Value;

   --  ------------------------------
   --  This bean provides some methods that can be used in a Method_Expression
   --  ------------------------------
   overriding
   function Get_Method_Bindings (From : in User_Bean)
                                 return Util.Beans.Methods.Method_Binding_Array_Access is
      pragma Unreferenced (From);
   begin
      return User_Bean_Binding'Access;
   end Get_Method_Bindings;

   --  ------------------------------
   --  Create the User_Bean bean instance.
   --  ------------------------------
   function Create_User_Bean (Module : in Twinlife.Users.Modules.User_Module_Access)
      return Util.Beans.Basic.Readonly_Bean_Access is
      Object : constant User_Bean_Access := new User_Bean;
   begin
      Object.Module := Module;
      return Object.all'Access;
   end Create_User_Bean;

end Twinlife.Users.Beans;

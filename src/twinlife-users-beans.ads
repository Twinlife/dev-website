-----------------------------------------------------------------------
--  twinlife-users-beans -- Beans for module users
--  Copyright (c) 2026 twinlife SA.
--  Written by Stephane.Carrez (Stephane.Carrez@twin.life)
--  SPDX-License-Identifier: Apache-2.0
-----------------------------------------------------------------------

with Ada.Strings.Unbounded;

with Util.Beans.Basic;
with Util.Beans.Objects;
with Util.Beans.Methods;
with Twinlife.Users.Modules;
package Twinlife.Users.Beans is

   type User_Bean is new Util.Beans.Basic.Bean
     and Util.Beans.Methods.Method_Bean with record
      Module : Twinlife.Users.Modules.User_Module_Access := null;
      Count  : Natural := 0;
   end record;
   type User_Bean_Access is access all User_Bean'Class;

   --  Get the value identified by the name.
   overriding
   function Get_Value (From : in User_Bean;
                       Name : in String) return Util.Beans.Objects.Object;

   --  Set the value identified by the name.
   overriding
   procedure Set_Value (From  : in out User_Bean;
                        Name  : in String;
                        Value : in Util.Beans.Objects.Object);

   --  This bean provides some methods that can be used in a Method_Expression
   overriding
   function Get_Method_Bindings (From : in User_Bean)
                                 return Util.Beans.Methods.Method_Binding_Array_Access;

   --  Example of action method.
   procedure Action (Bean    : in out User_Bean;
                     Outcome : in out Ada.Strings.Unbounded.Unbounded_String);

   --  Create the Users_Bean bean instance.
   function Create_User_Bean (Module : in Twinlife.Users.Modules.User_Module_Access)
      return Util.Beans.Basic.Readonly_Bean_Access;

end Twinlife.Users.Beans;

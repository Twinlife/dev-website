-----------------------------------------------------------------------
--  twinlife -- twinlife applications
--  Copyright (c) 2026 twinlife SA.
--  Written by Stephane.Carrez (Stephane.Carrez@twin.life)
--  SPDX-License-Identifier: Apache-2.0
-----------------------------------------------------------------------
with Util.Beans.Objects;
with Util.Beans.Basic;
with AWA.Comments.Beans;
with AWA.Comments.Modules;
package Twinlife.Beans is

   package UBO renames Util.Beans.Objects;

   type Comment_Bean is new AWA.Comments.Beans.Comment_Bean with record
      C1, C2, C3, C4, C5, C6 : UString;
   end record;

   --  Get the value identified by the name.
   overriding
   function Get_Value (From : in Comment_Bean;
                       Name : in String) return UBO.Object;

   --  Set the value identified by the name.
   overriding
   procedure Set_Value (From  : in out Comment_Bean;
                        Name  : in String;
                        Value : in UBO.Object);

   overriding
   procedure Create (Bean    : in out Comment_Bean;
                     Outcome : in out UString);

   --  Create a new comment bean instance.
   function Create_Comment_Bean (Module : in AWA.Comments.Modules.Comment_Module_Access)
                                 return Util.Beans.Basic.Readonly_Bean_Access;

end Twinlife.Beans;

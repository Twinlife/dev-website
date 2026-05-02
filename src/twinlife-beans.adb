-----------------------------------------------------------------------
--  twinlife -- twinlife applications
--  Copyright (c) 2026 twinlife SA.
--  Written by Stephane.Carrez (Stephane.Carrez@twin.life)
--  SPDX-License-Identifier: Apache-2.0
-----------------------------------------------------------------------
with AWA.Users.Models;
with AWA.Services.Contexts;
with Twinlife.Users.Modules;
package body Twinlife.Beans is

   --  Get the value identified by the name.
   overriding
   function Get_Value (From : in Comment_Bean;
                       Name : in String) return UBO.Object is
   begin
      if Name = "c1" then
         return UBO.To_Object (From.C1);
      elsif Name = "c2" then
         return UBO.To_Object (From.C2);
      elsif Name = "c3" then
         return UBO.To_Object (From.C3);
      elsif Name = "c4" then
         return UBO.To_Object (From.C4);
      elsif Name = "c5" then
         return UBO.To_Object (From.C5);
      elsif Name = "c6" then
         return UBO.To_Object (From.C6);
      else
         return AWA.Comments.Beans.Comment_Bean (From).Get_Value (Name);
      end if;
   end Get_Value;

   --  Set the value identified by the name.
   overriding
   procedure Set_Value (From  : in out Comment_Bean;
                        Name  : in String;
                        Value : in UBO.Object) is
   begin
      if Name = "c1" then
         From.C1 := UBO.To_Unbounded_String (Value);
      elsif Name = "c2" then
         From.C2 := UBO.To_Unbounded_String (Value);
      elsif Name = "c3" then
         From.C3 := UBO.To_Unbounded_String (Value);
      elsif Name = "c4" then
         From.C4 := UBO.To_Unbounded_String (Value);
      elsif Name = "c5" then
         From.C5 := UBO.To_Unbounded_String (Value);
      elsif Name = "c6" then
         From.C6 := UBO.To_Unbounded_String (Value);
      else
         AWA.Comments.Beans.Comment_Bean (From).Set_Value (Name, Value);
      end if;
   end Set_Value;

   overriding
   procedure Create (Bean    : in out Comment_Bean;
                     Outcome : in out UString) is
      procedure Create_Comment;
      use type Ada.Strings.Unbounded.Unbounded_String;

      Module : constant Twinlife.Users.Modules.User_Module_Access
        := Twinlife.Users.Modules.Get_User_Module;
      User    : AWA.Users.Models.User_Ref;
      Session : AWA.Users.Models.Session_Ref;

      procedure Create_Comment is
      begin
         AWA.Comments.Beans.Comment_Bean (Bean).Create (Outcome);
      end Create_Comment;

      procedure Create_Comment_As is
         new AWA.Services.Contexts.Run_As (Create_Comment);
   begin
      Module.Register_User (Bean.C1 & Bean.C2 & Bean.C3 & Bean.C4 & Bean.C5 & Bean.C6,
                            User, Session);
      Create_Comment_As (User, Session);
   end Create;

   --  Create a new comment bean instance.
   function Create_Comment_Bean (Module : in AWA.Comments.Modules.Comment_Module_Access)
                                 return Util.Beans.Basic.Readonly_Bean_Access is
      Result : constant AWA.Comments.Beans.Comment_Bean_Access := new Comment_Bean;
   begin
      Result.Module := Module;
      return Result.all'Access;
   end Create_Comment_Bean;

end Twinlife.Beans;

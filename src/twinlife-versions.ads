-----------------------------------------------------------------------
--  twinlife-versions -- Information about twinme & Skred versions
--  Copyright (c) 2026 twinlife SA.
--  Written by Stephane.Carrez (Stephane.Carrez@twin.life)
--  SPDX-License-Identifier: Apache-2.0
-----------------------------------------------------------------------
with Ada.Calendar;
with Util.Beans.Objects;
with Util.Beans.Basic;
with Util.Beans.Methods;
with Twinlife.Rest.Models;
with AWA.Events;
private with Ada.Containers.Doubly_Linked_Lists;
private with Util.Beans.Lists.Strings;
package Twinlife.Versions is

   package UBO renames Util.Beans.Objects;

   package Event_Refresh is new AWA.Events.Definition ("refresh-version");

   type Versions_Type is limited private;

   function Create_Version_Bean return Util.Beans.Basic.Readonly_Bean_Access;

private

   type Version_Info is record
      Name        : UString;
      Timestamp   : Ada.Calendar.Time;
      Uri         : UString;
      Name_iOS    : UString;
      Android     : Twinlife.Rest.Models.TwinmeInfo_Type;
      IOS         : Twinlife.Rest.Models.TwinmeInfo_Type;
   end record;

   type Version_Bean is new Util.Beans.Basic.Bean
     and Util.Beans.Methods.Method_Bean with record
      Info        : Version_Info;
      Changes     : aliased Util.Beans.Lists.Strings.List_Bean;
   end record;
   type Version_Bean_Access is access all Version_Bean'Class;

   --  Get the value identified by the name.
   overriding
   function Get_Value (From : Version_Bean;
                       Name : String) return UBO.Object;

   --  Set the value identified by the name.
   overriding
   procedure Set_Value (From  : in out Version_Bean;
                        Name  : in String;
                        Value : in Util.Beans.Objects.Object);

   --  This bean provides some methods that can be used in a Method_Expression
   overriding
   function Get_Method_Bindings (From : in Version_Bean)
                                 return Util.Beans.Methods.Method_Binding_Array_Access;

   --  Refresh the version by getting the JSON content.
   procedure Refresh (Bean    : in out Version_Bean;
                      Event   : in AWA.Events.Module_Event'Class);

   package Version_List is
      new Ada.Containers.Doubly_Linked_Lists (Version_Info);

   protected type Version_Data is

      procedure Get_Version (Version : in out Version_Info);

      procedure Set_Version (Version : in Version_Info);

   private
      Versions : Version_List.List;
   end Version_Data;

   type Versions_Type is limited record
      Versions : Version_Data;
   end record;

end Twinlife.Versions;

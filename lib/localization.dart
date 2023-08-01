// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter_localization/flutter_localization.dart';

export 'localization/en_US.dart';

final localization = FlutterLocalization.instance;

mixin AppLocale {
  static const eventsPage_Title = 'eventsPage_Title';
  static const eventsPage_NoUpcomming = 'eventsPage_NoUpcomming';

  static const calendarPage_Title = 'calendarPage_Title';

  static const groupsPage_Title = 'groupsPage_Title';
  static const groupsPage_JoinGroupButtonLabel = 'groupsPage_JoinGroupButtonLabel';
  static const groupsPage_CreateGroupButtonLabel = 'groupsPage_CreateGroupButtonLabel';
  static const groupsPage_NoJoinedGroups = 'groupsPage_NoJoinedGroups';

  static const joinGroup_InvalidCode = 'joinGroup_InvalidCode';
  static const joinGroup_JoinButtonLabel = 'joinGroup_JoinButtonLabel';
  static const joinGroup_ScanQRCode = 'joinGroup_ScanQRCode';

  static const createGroup_AppBar_Title = 'createGroup_AppBar_Title';

  static const createGroup_Name_Label = 'createGroup_Name_Label';
  static const createGroup_Name_Explanation = 'createGroup_Name_Explanation';
  static const createGroup_Name_Error_NoValue = 'createGroup_Name_Error_NoValue';
  static const createGroup_Name_Error_TrimInvalid = 'createGroup_Name_Error_TrimInvalid';
  static const createGroup_Name_Error_TooShort = 'createGroup_Name_Error_TooShort';
  static const createGroup_Name_Error_TooLong = 'createGroup_Name_Error_TooLong';

  static const createGroup_About_Label = 'createGroup_About_Label';
  static const createGroup_About_Explanation = 'createGroup_About_Explanation';
  static const createGroup_About_Error_TooLong = 'createGroup_About_Error_TooLong';

  static const createGroup_IconBanner_Explanation = 'createGroup_IconBanner_Explanation';
  static const createGroup_IconBanner_ErrorLoading = 'createGroup_IconBanner_ErrorLoading';

  static const settingsPage_Title = 'settingsPage_Title';
}

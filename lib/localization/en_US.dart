// ignore_for_file: file_names, constant_identifier_names

import 'package:trumpet/localization.dart';

const Map<String, dynamic> en_US = {
  AppLocale.eventsPage_Title: 'Events',
  AppLocale.eventsPage_NoUpcomming: 'No upcomming events',
  //
  AppLocale.calendarPage_Title: 'Calendar',
  //
  AppLocale.groupsPage_Title: 'Groups',
  AppLocale.groupsPage_JoinGroupButtonLabel: 'Join group',
  AppLocale.groupsPage_CreateGroupButtonLabel: 'Create group',
  AppLocale.groupsPage_NoJoinedGroups: 'You haven\'t joined any groups yet',
  //
  AppLocale.joinGroup_InvalidCode: 'Invalid code',
  AppLocale.joinGroup_JoinButtonLabel: 'Join',
  AppLocale.joinGroup_ScanQRCode: 'Scan QR Code',
  //
  AppLocale.createGroup_AppBar_Title: 'Create group',
  //
  AppLocale.createGroup_Name_Label: 'Name',
  AppLocale.createGroup_Name_Explanation: 'Use the shortest complete name for your group. Your name will only be visible to members of your group.',
  AppLocale.createGroup_Name_Error_NoValue: 'Provide a name',
  AppLocale.createGroup_Name_Error_TrimInvalid: 'Name cannot begin or end with a space',
  AppLocale.createGroup_Name_Error_TooShort: 'Must be at least three characters',
  AppLocale.createGroup_Name_Error_TooLong: 'Must be less than 32 characters',
  //
  AppLocale.createGroup_About_Label: 'About',
  AppLocale.createGroup_About_Explanation: 'Describe your group or, if your group has a slogan, use it here.',
  AppLocale.createGroup_About_Error_TooLong: 'Must be less than 200 characters',
  //
  AppLocale.createGroup_IconBanner_Explanation: 'Simple and recognizable patterns help users quickly identify your group. Graphics are preferred over pictures. Use acronyms rather than text where possible.',
  AppLocale.createGroup_IconBanner_ErrorLoading: 'An error occured while trying to decode the image',
  //
  AppLocale.createGroup_Done_Success: 'All done! Your group has been created.',
  AppLocale.createGroup_Done_Error: 'An error occured while creating your group.',
  //
  AppLocale.settingsPage_Title: 'Settings',
};

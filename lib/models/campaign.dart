
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {

  String currentUserUid;
  String campaignUid;
  String campaignImgUrl;
  String campaignTitle;
  String campaignDescription;
  String campaignThankYouVideoUrl;
  String campaignThankYouText;
  bool jointCampaign;
  bool nsfwContent;
  bool campaignIsEarningBased;
  bool campaignPaymentScheduleIsPerMonth;
  bool campaignEarningsAreVisible;
  var time;
  String campaignOwnerName;
  String campaignOwnerPhotoUrl;

  Campaign({
    this.currentUserUid,
    this.campaignUid = "",
    this.campaignImgUrl,
    this.campaignTitle,
    this.campaignDescription,
    this.campaignThankYouVideoUrl,
    this.campaignThankYouText,
    this.jointCampaign,
    this.nsfwContent,
    this.campaignIsEarningBased,
    this.campaignPaymentScheduleIsPerMonth,
    this.campaignEarningsAreVisible,
    this.time,
    this.campaignOwnerName,
    this.campaignOwnerPhotoUrl
  });

  Map toMap(Campaign campaign) {
    var data = Map<String, dynamic>();
    data['ownerUid'] = campaign.currentUserUid;
    data['campaignUid'] = campaign.campaignUid;
    data['campaignImgUrl'] = campaign.campaignImgUrl;
    data['campaignTitle'] = campaign.campaignTitle;
    data['campaignDescription'] = campaign.campaignDescription;
    data['campaignThankYouVideoUrl'] = campaign.campaignThankYouVideoUrl;
    data['campaignThankYouText'] = campaign.campaignThankYouText;
    data['jointCampaign'] = campaign.jointCampaign;
    data['nsfwContent'] = campaign.nsfwContent;
    data['campaignIsEarningBased'] = campaign.campaignIsEarningBased;
    data['campaignPaymentScheduleIsPerMonth'] = campaign.campaignPaymentScheduleIsPerMonth;
    data['campaignEarningsAreVisible'] = campaign.campaignEarningsAreVisible;
    data['time'] = campaign.time;
    data['campaignOwnerName'] = campaign.campaignOwnerName;
    data['campaignOwnerPhotoUrl'] = campaign.campaignOwnerPhotoUrl;
    return data;
  }

  Campaign.fromMap(Map<String, dynamic> mapData) {
    this.currentUserUid = mapData['ownerUid'];
    this.campaignUid = mapData['campaignUid'];
    this.campaignImgUrl = mapData['campaignImgUrl'];
    this.campaignTitle = mapData['campaignTitle'];
    this.campaignDescription = mapData['campaignDescription'];
    this.campaignThankYouVideoUrl = mapData['campaignThankYouVideoUrl'];
    this.campaignThankYouText = mapData['campaignThankYouText'];
    this.jointCampaign = mapData['jointCampaign'];
    this.nsfwContent = mapData['nsfwContent'];
    this.campaignIsEarningBased = mapData['campaignIsEarningBased'];
    this.campaignPaymentScheduleIsPerMonth = mapData['campaignPaymentScheduleIsPerMonth'];
    this.campaignEarningsAreVisible = mapData['campaignEarningsAreVisible'];
    this.time = mapData['time'];
    this.campaignOwnerName = mapData['campaignOwnerName'];
    this.campaignOwnerPhotoUrl = mapData['campaignOwnerPhotoUrl'];
  }

}
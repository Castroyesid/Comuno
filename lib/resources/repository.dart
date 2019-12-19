import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:comuno/models/message.dart';
import 'package:comuno/models/user.dart';
import 'package:comuno/resources/firebase_provider.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';

class Repository {

  final _firebaseProvider = FirebaseProvider();

  Future<void> addDataToDb(FirebaseUser user) => _firebaseProvider.addDataToDb(user);
  
  Future<FirebaseUser> signInGoogle() => _firebaseProvider.signInGoogle();

  Future<FirebaseUser> signInTwitter() => _firebaseProvider.signInTwitter();

  Future<bool> authenticateUser(FirebaseUser user) => _firebaseProvider.authenticateUser(user);

  Future<FirebaseUser> getCurrentUser() => _firebaseProvider.getCurrentUser();

//  Future<TwitterSession> getCurrentTwitterSession() => _firebaseProvider.getCurrentTwitterSession();

  Future<void> signOut() => _firebaseProvider.signOut();

  Future<String> uploadImageToStorage(File imageFile) => _firebaseProvider.uploadImageToStorage(imageFile);

  Future<void> addPostToDb(User currentUser, String imgUrl, String caption, String text, String location) => _firebaseProvider.addPostToDb(currentUser, imgUrl, caption, text, location);

  Future<void> addCampaignToDb(
      User currentUser, String campaignImgUrl, String campaignTitle, String campaignDescription,
      String campaignThankYouVideoUrl, String campaignThankYouText,
      bool jointCampaign, bool nsfwContent, bool campaignIsEarningBased,
      bool campaignPaymentScheduleIsPerMonth, bool campaignEarningsAreVisible
      ) => _firebaseProvider.addCampaignToDb(
        currentUser, campaignImgUrl, campaignTitle, campaignDescription,
      campaignThankYouVideoUrl, campaignThankYouText,
      jointCampaign, nsfwContent, campaignIsEarningBased,
      campaignPaymentScheduleIsPerMonth, campaignEarningsAreVisible
  );

  Future<void> addSupportedCampaignToUser(
      User currentUser, String campaignImgUrl, String campaignUid,
      String campaignTitle, String campaignDescription,
      String campaignThankYouVideoUrl, String campaignThankYouText,
      bool jointCampaign, bool nsfwContent, bool campaignIsEarningBased,
      bool campaignPaymentScheduleIsPerMonth, bool campaignEarningsAreVisible,
      campaignOwnerName, campaignOwnerPhotoUrl
      ) => _firebaseProvider.addSupportedCampaignToUser(
        currentUser, campaignImgUrl, campaignUid, campaignTitle,
      campaignDescription, campaignThankYouVideoUrl, campaignThankYouText,
      jointCampaign, nsfwContent, campaignIsEarningBased,
      campaignPaymentScheduleIsPerMonth, campaignEarningsAreVisible,
      campaignOwnerName, campaignOwnerPhotoUrl
  );

  Future<void> removeSupportedCampaignToUser(User currentUser, String documentId) => _firebaseProvider.removeSupportedCampaignToUser(currentUser, documentId);

  Future<DocumentReference> saveGoogleNewsToStorage(String postId, String urlToImage, String title, String publishedAt, String description) => _firebaseProvider.saveGoogleNewsToStorage(postId, urlToImage, title, publishedAt, description);

  Future<DocumentReference> saveTwitterNewsToStorage(String userUid, String postId, String urlToImage, String title, String publishedAt, String description) => _firebaseProvider.saveTwitterNewsToStorage(userUid, postId, urlToImage, title, publishedAt, description);

  Future<User> retrieveUserDetails(FirebaseUser user) => _firebaseProvider.retrieveUserDetails(user);

  Future<List<DocumentSnapshot>> retrieveUserPosts(String userId) => _firebaseProvider.retrieveUserPosts(userId);

  Future<List<DocumentSnapshot>> retrieveUserCampaigns(String userId) => _firebaseProvider.retrieveUserCampaigns(userId);

  Future<List<DocumentSnapshot>> retrieveUserSupportedCampaigns(String userId) => _firebaseProvider.retrieveUserSupportedCampaigns(userId);

  Future<List<DocumentSnapshot>> fetchPostComments(DocumentReference reference) => _firebaseProvider.fetchPostCommentDetails(reference);

  Future<List<DocumentSnapshot>> fetchPostLikes(DocumentReference reference) => _firebaseProvider.fetchPostLikeDetails(reference);

  Future<bool> checkIfUserLikedOrNot(String userId, DocumentReference reference) => _firebaseProvider.checkIfUserLikedOrNot(userId, reference);

  Future<List<DocumentSnapshot>> retrievePosts(FirebaseUser user) => _firebaseProvider.retrievePosts(user);

  Future<List<DocumentSnapshot>> fetchGoogleNews() => _firebaseProvider.fetchGoogleNews();

  Future<List<DocumentSnapshot>> fetchTwitterNews(String uid) => _firebaseProvider.fetchTwitterNews(uid);

  Future<List<String>> fetchAllUserNames(FirebaseUser user) => _firebaseProvider.fetchAllUserNames(user);

  Future<String> fetchUidBySearchedName(String name) => _firebaseProvider.fetchUidBySearchedName(name);

  Future<User> fetchUserDetailsById(String uid) => _firebaseProvider.fetchUserDetailsById(uid);

  Future<void> followUser({String currentUserId, String followingUserId}) => _firebaseProvider.followUser(currentUserId: currentUserId, followingUserId: followingUserId);

  Future<void> unFollowUser({String currentUserId, String followingUserId}) => _firebaseProvider.unFollowUser(currentUserId: currentUserId, followingUserId: followingUserId);

  Future<bool> checkIsFollowing(String name, String currentUserId) => _firebaseProvider.checkIsFollowing(name, currentUserId);

  Future<List<DocumentSnapshot>> fetchStats({String uid, String label}) => _firebaseProvider.fetchStats(uid: uid, label: label);

  Future<void> updatePhoto(String photoUrl, String uid) => _firebaseProvider.updatePhoto(photoUrl, uid);

  Future<void> updateDetails(String uid, String name, String bio, String email) => _firebaseProvider.updateDetails(uid, name, bio, email);

  Future<List<String>> fetchUserNames(FirebaseUser user) => _firebaseProvider.fetchUserNames(user);

  Future<List<User>> fetchAllUsers(FirebaseUser user) => _firebaseProvider.fetchAllUsers(user);

  void uploadImageMsgToDb(String url, String receiverUid, String senderUid) => _firebaseProvider.uploadImageMsgToDb(url, receiverUid, senderUid);

  Future<void> addMessageToDb(Message message, String receiverUid) => _firebaseProvider.addMessageToDb(message, receiverUid);

  Future<List<DocumentSnapshot>> fetchFeed(FirebaseUser user) => _firebaseProvider.fetchFeed(user);

  Future<List<String>> fetchFollowingUIDs(FirebaseUser user) => _firebaseProvider.fetchFollowingUids(user);

  //Future<List<DocumentSnapshot>> retrievePostByUID(String uid) => _firebaseProvider.retrievePostByUID(uid);

}
# LayerUIKit Change Log

## 0.2.2

### Backwards Incompatibility

`LYRUIConversationViewController` now sends mixed content (e.g. an image and text) in multiple messages, i.e. one message per piece of content (e.g. one message with an image part and another message with a text part). Correspondingly, it now displays one cell for each message. The previous behavior was to display one cell for each message part. The default message cells assume that each message only has one part. So a multi-part message (e.g. one sent with the previous behavior) will only have its first part displayed.

### Public API Changes
* Added `nameLabel` property to `LYRUIParticipantTableViewCell`.
* Added `collectionView` property to `LYRUIConversationViewController`.
* Added `queryController` property to `LYRUIConversationViewController`.
* Added `queryController` property to `LYRUIConversationListViewController`.
* Added `bubbleViewCornerRadius` property to `LYRUIMessageCollectionViewCell`.  
* Added `avatarImageViewCornerRadius` property to `LYRUIMessageCollectionViewCell`.
* Changed `backgroundColor` property to `cellBackgroundColor` on `LYRUIConversationTableViewCell`.
* Removed `updateWithBubbleViewWidth:` from `LYRUIMessageCollectionViewCell`.
* Changed `-[<LYRUIConversationViewControllerDataSource> conversationViewController:pushNotificationTextForMessageParts:]` to `conversationViewController:pushNotificationTextForMessagePart:`. That is, one message part is passed instead of an array of message parts.
* Changed `-[<LYRUIMessagePresenting> presentMessagePart:]` to `presentMessage:`. That is, a message is passed instead of a message part.
* Changed `-[<LYRUIAddressBarControllerDataSource> searchForParticipantsMatchingText:completion:]` to `addressBarViewController:searchForParticipantsMatchingText:completion:`. That is, the view controller is now passed as the first parameter. This callback also now controls the order of search results by providing an `NSArray` instead of an `NSSet` in the completion block.
* Changed `-[LYRUIMessageInputToolbarDelegate messageInputToolbarDidBeginTyping:]` to `messageInputToolbarDidType:`.
* `-[LYRUIMessageInputToolbar insertLocation:]` has been removed since it was unused.
* Removed `maxHeight` property from `LYRUIMessageComposeTextView`. Use the `maxNumberOfLines` property of `LYRUIMessageInputToolbar` instead.
* Removed `-[LYRUIMessageComposeTextView insertImage:]`. Use `-[LYRUIMessageInputToolbar insertImage:]` instead.
* Removed `-[LYRUIMessageComposeTextView removeAttachements]`. It doesn't have a replacement since it was meant for internal use only.
* Changed `placeHolderText` property of `LYRUIMessageComposeTextView` to `placeholder`.
* Removed `pendingBubbleViewColor` property of `LYRUIMessageCollectionViewCell`.
* Changed `avatarImage` property of `LYRUIMessageCollectionViewCell` to `avatarImageView`.
* Removed `initialViewBackgroundColor` property of `LYRUIAvatarImageView`. Use `backgroundColor` instead.
* Changed `initialFont` property of `LYRUIAvatarImageView` to `initialsFont`.
* Changed `initialColor` property of `LYRUIAvatarImageView` to `initialsColor`.
* Changed `-[<LYRUIParticipantPickerControllerDelegate> participantSelectionViewControllerDidCancel:]` to `participantPickerControllerDidCancel:`.
* Changed `-[<LYRUIParticipantPickerControllerDelegate> participantSelectionViewController:didSelectParticipant:]` to `participantPickerController:didSelectParticipant:`.
* Changed `-[<LYRUIParticipantPickerDataSource> searchForParticipantsMatchingText:completion:]` to `participantPickerController:searchForParticipantsMatchingText:completion:`.
* Changed `-[<LYRUIParticipantPickerDataSource> participants]` to `participantsForParticipantPickerController:`.
* Changed `-[<LYRUIParticipantTableViewControllerDelegate> participantTableViewControllerDidSelectCancelButton]` to `participantTableViewControllerDidCancel:`.
* Removed `selectionIndicator` property from `LYRUIParticipantTableViewController`.
* Added `participantPickerController:didDeselectParticipant:` to `LYRUIParticipantPickerControllerDelegate`.
* Added `participantTableViewController:didDeselectParticipant:` to `LYRUIParticipantTableViewControllerDelegate`.
* Replaced `presentParticipant:`, `updateWithSortType:` and `shouldShowAvatarImage:` on `LYRUIParticipantPresenting` with `presentParticipant:withSortType:shouldShowAvatarImage:`.
* Changed `LYRUIParticipantPickerControllerSortTypeFirst` to `LYRUIParticipantPickerSortTypeFirstName`.
* Changed `LYRUIParticipantPickerControllerSortTypeLast` to `LYRUIParticipantPickerSortTypeLastName`.
* Changed `LYRUIPaticipantSectionHeaderView` to `LYRUIParticipantSectionHeaderView`.
* Removed `initWithKey:` from `LYRUIParticipantSectionHeaderView`.
* Changed `keyLabel` property to `nameLabel` on `LYRUIParticipantSectionHeaderView`.
* Removed `conversationListViewController:didSearchWithString:completion:` from `LYRUIConversationListViewControllerDataSource`.
* Changed `layerClient` property on `LYRUIConversationListViewController` from `readwrite` to `readonly`.

### Bug Fixes

* Fixed possibility of customizations via `UIAppearance` being overridden.
* Fixed issue related to sending a push notification with `(null)` text.
* Fixed typo for property `conversationLabelColor` on `LYRUIConversationTableViewCell`.
* Fixed typo in C function signature `LYRUILightGrayColor()`.
* Added logic to guard against messages with external content in applications using LayerKit v0.9.2 and previous.

### Enhancements
* Implemented `LayerUIKit` unit test suite.
* Re-implemented `LayerUIKit` mock objects.
* Re-factored `LayerUIKit` sample app to use new mock objects.
* Refactored internal constants.
* Added support for external content.

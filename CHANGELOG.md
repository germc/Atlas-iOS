# LayerUIKit Change Log

## 0.2.2

### Public API Changes
* Added `bubbleViewCornerRadius` property to `LYRUIMessageCollectionViewCell`.  
* Added `avatarImageViewCornerRadius` property to `LYRUIMessageCollectionViewCell`.

### Bug Fixes
* Fixed possibility of customizations via `UIAppearance` being overridden.
* Fixed issue related to sending a push notification with `(null)` text. 
* Fixed typo for property `conversationLabelColor` on `LYRUIConversationTableViewCell`.
* Fixed typo in C function signature `LYRUILightGrayColor()`.

### Enhancements
* Refactored internal constants.
* Added support for external content.

## x.x.x

### Backwards Incompatibility

`LYRUIConversationViewController` now sends mixed content (e.g. an image and text) in multiple messages, i.e. one message per piece of content (e.g. one message with an image part and another message with a text part). Correspondingly, it now displays one cell for each message. The previous behavior was to display one cell for each message part. The default message cells assume that each message only has one part. So a multi-part message (e.g. one sent with the previous behavior) will only have its first part displayed.

### Public API Changes

* `-[<LYRUIConversationViewControllerDataSource> conversationViewController:pushNotificationTextForMessageParts:]` is now `conversationViewController:pushNotificationTextForMessagePart:`. That is, one message part is passed instead of an array of message parts.
* `-[<LYRUIMessagePresenting> presentMessagePart:]` is now `presentMessage:`. That is, a message is passed instead of a message part.
* `-[LYRUIAddressBarControllerDataSource searchForParticipantsMatchingText:completion:]` is now `-[LYRUIAddressBarControllerDataSource addressBarViewController:searchForParticipantsMatchingText:completion:]`. That is, the view controller is now passed as the first parameter. This callback also now controls the order of search results by providing an `NSArray` instead of an `NSSet` in the completion block.
* `-[LYRUIMessageInputToolbarDelegate messageInputToolbarDidBeginTyping:]` has been renamed to `messageInputToolbarDidType:`.
* `-[LYRUIMessageInputToolbar insertLocation:]` has been removed since it was unused.
* The `maxHeight` property of `LYRUIMessageComposeTextView` has been removed. Use the `maxNumberOfLines` property of `LYRUIMessageInputToolbar` instead.
* `-[LYRUIMessageComposeTextView insertImage:]` has been removed. Use `-[LYRUIMessageInputToolbar insertImage:]` instead.
* `-[LYRUIMessageComposeTextView removeAttachements]` has been removed. It doesn't have a replacement since it was meant for internal use only.
* The `placeHolderText` property of `LYRUIMessageComposeTextView` is now `placeholder`.
* The unused `pendingBubbleViewColor` property of `LYRUIMessageCollectionViewCell` has been removed.
* The `avatarImage` property of `LYRUIMessageCollectionViewCell` is now `avatarImageView`.
* The `initialViewBackgroundColor` property of `LYRUIAvatarImageView` has been removed. Use `backgroundColor` instead.
* The `initialFont` property of `LYRUIAvatarImageView` is now `initialsFont`.
* The `initialColor` property of `LYRUIAvatarImageView` is now `initialsColor`.
* The `updateWithBubbleViewWidth:` method has been moved from `<LYRUIMessagePresenting>` to `LYRUIMessageCollectionViewCell` since the method applies specifically to the default cell class, not all cells.

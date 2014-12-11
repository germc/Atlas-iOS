# LayerUIKit Change Log

## x.x.x

### Public API Changes

* `-[LYRUIAddressBarControllerDataSource searchForParticipantsMatchingText:completion:]` is now `-[LYRUIAddressBarControllerDataSource addressBarViewController:searchForParticipantsMatchingText:completion:]`. That is, the view controller is now passed as the first parameter. This callback also now controls the order of search results by providing an `NSArray` instead of an `NSSet` in the completion block.
* `-[LYRUIMessageInputToolbarDelegate messageInputToolbarDidBeginTyping:]` has been renamed to `messageInputToolbarDidType:`.
* The `maxHeight` property of `LYRUIMessageComposeTextView` has been removed. Use the `maxNumberOfLines` property of `LYRUIMessageInputToolbar` instead.
* `-[LYRUIMessageComposeTextView insertImage:]` has been removed. Use `-[LYRUIMessageInputToolbar insertImage:]` instead.
* `-[LYRUIMessageComposeTextView removeAttachements]` has been removed. It doesn't have a replacement since it was meant for internal use only.
* The `placeHolderText` property of `LYRUIMessageComposeTextView` is now `placeholder`.
* The unused `pendingBubbleViewColor` property of `LYRUIMessageCollectionViewCell` has been removed.
* The `avatarImage` property of `LYRUIMessageCollectionViewCell` is now `avatarImageView`.
* The `initialViewBackgroundColor` property of `LYRUIAvatarImageView` has been removed. Use `backgroundColor` instead.
* The `initialFont` property of `LYRUIAvatarImageView` is now `initialsFont`.
* The `initialColor` property of `LYRUIAvatarImageView` is now `initialsColor`.

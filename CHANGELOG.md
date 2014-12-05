# LayerUIKit Change Log

## x.x.x

### Public API Changes

* `-[LYRUIAddressBarControllerDataSource searchForParticipantsMatchingText:completion:]` is now `-[LYRUIAddressBarControllerDataSource addressBarViewController:searchForParticipantsMatchingText:completion:]`. That is, the view controller is now passed as the first parameter. This callback also now controls the order of search results by providing an `NSArray` instead of an `NSSet` in the completion block.

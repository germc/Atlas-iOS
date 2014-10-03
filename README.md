#LayerUIKit
LayerUIKit provides lightweight, customizable user interface components that allow developers to quickly build dynamic and responsive user interfaces on top of the LayerKit SDK.

##Installation
LayerUIKit can be easily installed via Cocoapods. Include the following in your Podfile.
```
pod 'LayerUIKit', git: 'git@github.com:layerhq/LayerUIKit'
```

##Whats Included
LayerUIKit provides the following components that must be used in conjunction with LayerKit.

1. `LYRUIConversationViewController` - Displays an individual Layer conversation.
2. `LYRUIConversationListViewController` - Displays a list of Layer conversation.

LayerUIKit provides the following components that can be used independently of LayerKit.

1. `LYRUIParticipantPicker` - Displays a list of participants conforming to the `LYRUIParticipant` protocol.
2. `LYRUIMessageInputToolBar` - A message input toolbar similar in functionality to the toolbar used in iMessage.

## Getting Started
1. **Subclass** - Subclass the `LYRUIConversationViewController` or `LYRUIConversationListViewController`
2. **Implement** - Both controllers declare delegate and datasource protocols. Your subclasses must implement these protocols.
3. **Customize** - The LayerUIKit leverages the UIAppearance protocol to allow for effortless customization of components.
4. **Communicate** - Use the LayerKit SDK and the LayerUIKit to build compelling messaging applications.

##MIMETypes
LayerUIKit provides support for multiple different MIMETypes. Implementing applications should ensure that their LYRMessagePart objects are instantiated with these MIMEType strings.

```
NSString *LYRUIMIMETypeTextPlain; /// text/plain
NSString *LYRUIMIMETypeImagePNG;  /// image/png
NSString *LYRUIMIMETypeImageJPEG;  /// image/jpeg
NSString *LYRUIMIMETypeLocation;  /// location
```

##Sychronization Updates

##Components
###LYRUIConversationListViewController
The `LYRUIConversationListViewController` provides a customizable UITableViewController subclass for displaying a list of Layer conversations. Conversations are represented by a Conversation label, the latest message content, and the latest message date. The controller handles fetching and ordering conversation based on the latest message date.

####Initializer
The `LYRUIConversationListViewController` is initialized with a LYRClient object.

```
LYRUIConversationListViewController *viewController = [LYRUIConversationListViewController conversationListViewControllerWithLayerClient:layerClient];
```

####Customization
The `LYRUIConverationListViewController` displays `LYRUIConversationTableViewCells`. The cells themselves provide for customization via UIAppearanceSelectors.

```
[[LYRUIConversationTableViewCell appearance] setConversationLabelFont:[UIFont boldSystemFontOfSize:14]];
[[LYRUIConversationTableViewCell appearance] setConversationLabelColor:[UIColor blackColor]];
 ```

###LYRUIConversationViewController
The `LYRUIConversationViewController` provides a customizable `UICollectionViewController` subclass for displaying individual Layer conversations. The controller is initialized with and `LYRClient` object and an `LYRConversation` object. It handles fetching, displaying and sending messages via LayerKit. The controller leverages the `LYRUIMessageInputToolbar` object to allow for text and content input.

####Initializer

```
LYRUIConversationViewController *viewController = [LYRUIConversationViewController conversationViewControllerWithConversation:conversation layerClient:self.layerClient];
```

####Customization
The `LYRUIConverationViewController` displays both incoming and outgoing flavors of `LYRUIMessageCollectionViewCell`. The cells themselves provide for customization via UIAppearanceSelectors.

```
[[LYRUIOutgoingMessageCollectionViewCell appearance] setMessageTextColor:[UIColor whiteColor]];
[[LYRUIOutgoingMessageCollectionViewCell appearance] setMessageTextFont:[UIFont systemFontOfSize:14]];
[[LYRUIOutgoingMessageCollectionViewCell appearance] setBubbleViewColor:[UIColor blueColor]];
```

###LYRUIParticipantPicker
The `LYRUIParticipantPickerController` provides a `UINavigationController` subclass that displays a list of users conforming to the `LYRUIParticipant` protocol. The controller provides support for sorting and ordering participants based on either first or last name. The controller also provides multi-selection support and an optional selection indicator.

####Initializer
The `LYRUIParticipantPickerController` is initialized with an object conforming to the `LYRUIParticipantPickerDataSource` and a sortType.

```
LYRUIParticipantPickerSortType sortType = LYRUIParticipantPickerControllerSortTypeFirst;
LYRUIParticipantPickerController *controller = [LYRUIParticipantPickerController participantPickerWithDataSource:dataSource
                                                                                                        sortType:sortType];
```

####Customization
The `LYRUIParticipantPickerController` displays `LYRUIParticipantTableViewCells`. The cells themselves provide for customization via UIAppearanceSelectors.

```
[[LYRUIParticipantTableViewCell appearance] setTitleColor:[UIColor blackColor]];
[[LYRUIParticipantTableViewCell appearance] setTitleFont:[UIFont systemFontOfSize:14]];
```

###LYRUIMessageInputToolbar
The `LYRMessageInputToolbar` provides a `UIToolbar` subclass that supports text and image input. The toolbar handles auto-resizing itself relative to its content.

####Initializer
The `LYRMessageInputToolbar` is initialized with a UIViewController object and sets itself as the inputAccessoryView of the ViewController. In order to do this, the `inputAcccessoryView` property of the view controller must first be re-declared in the implementation file of the ViewController class.

```
self.inputAccessoryView = [LYRUIMessageInputToolbar inputToolBarWithViewController:self];
```
Once initialized, the controller manages resizing itself relative to its content, and animation so that it sticks to the top of the keyboard.

###Presenters
While the LayerUIKit does provide highly customizable TableView and CollectionView cells, advanced customization of the UI components can be done by implementing custom cells and setting the component's `cellClass` property. The LayerUIKit component CollectionView and TableView Cells share a common Presenter pattern where each cell displayed in a Component conforms to a specific presenter protocol. If you would like to swap out the default cells for cells that you build, this can easily accomplished via implementing cells that conform to the presenter patterns and setting the `cellClass` property.

The presenters are `LYRUIParticipantPresenting`, `LYRUIConversationPresenting`, and `LYRUIMessagePresenting`.

##Contributing

##Contact
LayerKit was developed in San Francisco by the Layer team. If you have any technical questions or concerns about this project feel free to reach out to engineers responsible for the development:

* [Kevin Coleman](mailto:kevin@layer.com)
* [Blake Watters](mailto:blake@layer.com)

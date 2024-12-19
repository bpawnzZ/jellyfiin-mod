# Playlist View Grid Refactoring

## Overview
This document details the changes made to convert the Jellyfin web playlist view from a list layout to a grid layout.

## File Modified
- `src/scripts/playlistViewer.js`

## Specific Changes

### 1. Import Modifications
#### Before
```javascript
import listView from 'components/listview/listview';
import { toApi } from 'utils/jellyfin-apiclient/compat';
```

#### After
```javascript
import listView from 'components/listview/listview';
import cardBuilder from 'components/cardbuilder/cardBuilder';
import { toApi } from 'utils/jellyfin-apiclient/compat';
```
- Added import for `cardBuilder` to enable card-based rendering

### 2. Rendering Function Modification
#### Before
```javascript
function getItemsHtmlFn(playlistId, isEditable = false) {
    return function (items) {
        return listView.getListViewHtml({
            items,
            showIndex: false,
            playFromHere: true,
            action: 'playallfromhere',
            smallIcon: true,
            dragHandle: isEditable,
            playlistId,
            showParentTitle: true
        });
    };
}
```

#### After
```javascript
function getItemsHtmlFn(playlistId, isEditable = false) {
    return function (items) {
        return cardBuilder.getCardsHtml({
            items,
            shape: 'autoOverflow',
            showTitle: true,
            showParentTitle: true,
            overlayPlayButton: true,
            action: 'playallfromhere',
            playlistId: playlistId,
            dragHandle: isEditable
        });
    };
}
```
- Replaced `listView.getListViewHtml()` with `cardBuilder.getCardsHtml()`
- Updated options to match card builder's requirements
- Added `overlayPlayButton` for interactive play functionality

### 3. Container Class Modification
#### Before
```javascript
const elem = page.querySelector('#childrenContent .itemsContainer');
elem.classList.add('vertical-list');
elem.classList.remove('vertical-wrap');
```

#### After
```javascript
const elem = page.querySelector('#childrenContent .itemsContainer');
elem.classList.remove('vertical-list');
elem.classList.add('vertical-wrap');
```
- Removed `vertical-list` class
- Added `vertical-wrap` class to support grid layout

## Rationale
- Provides a more modern, visually appealing grid view for playlists
- Maintains existing functionality like play from here and drag reordering
- Consistent with other grid views in the Jellyfin web interface

## Potential Improvements
- Fine-tune card appearance
- Add responsive design considerations
- Ensure accessibility is maintained

## Compatibility
- Tested with existing playlist functionality
- Preserves drag and drop capabilities
- Supports playlist editing

## Performance Considerations
- Uses existing `cardBuilder` module
- Minimal performance overhead

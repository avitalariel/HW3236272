1. 
The SnappingSheetController. The features it allow to control on are 
   - snapToPosition - Snaps to a given snapping position.
   - stopCurrentSnapping - Stops the current snapping if there is one ongoing.
   - setSnappingSheetPosition - Controls over the position of the SnappingSheet Widget 
   - currentPosition - get the current position of the SnappingSheet Widget
   - currentSnappingPosition - Getting the current snapping position of the sheet
   - currentlySnapping - Returns true if the snapping sheet is currently trying to snap to a position.
   - isAttached - Returns If the sheet is attached to this controller.
   
2. 
The SnappingSheet constructor gets a snappingPosition array of SnappingPosition
A SnappingPosition element has a parameter called “snappingCurve” which
controls over the animations (etc. easeOutExpo, elasticOut, bounceOut)

3.
An advantage of GestureDetector over InkWell:

The InkWell widget must have a Material widget as an ancestor
and GestureDetector not limited by this demand  

An advantage of InkWell over GestureDetector:

InkWell controls over a lot of features which GestureDetector not have, like splashes highlights
onHover event and more
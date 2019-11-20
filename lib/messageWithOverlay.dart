import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MessagesWithOverlay extends StatefulWidget {
  @override
  _MessagesWithOverlayState createState() => _MessagesWithOverlayState();
}

class _MessagesWithOverlayState extends State<MessagesWithOverlay> {
  final FocusNode _focusNode = FocusNode();
  bool isOpen = false;
  OverlayEntry _overlayEntry;

  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      print('hit');
      if (_focusNode.hasFocus) {
        this._overlayEntry = this._createOverlayEntry();
        Overlay.of(context).insert(this._overlayEntry);
      } else {
        this._overlayEntry.remove();
      }
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;

    return OverlayEntry(
        builder: (context) => Positioned(
              width: MediaQuery.of(context).size.width,
              child: CompositedTransformFollower(
                link: this._layerLink,
                showWhenUnlinked: false,
                offset: Offset(-MediaQuery.of(context).size.width * .7,
                    size.height - 130.0),
                child: Material(
                  color: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: Colors.white38,
                            border: Border.all(
                              color: Colors.blue[200],
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.favorite),
                            onPressed: () {},
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: Colors.white38,
                              border: Border.all(
                                color: Colors.blue[200],
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.thumb_down),
                              onPressed: () {},
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: Colors.white38,
                            border: Border.all(
                              color: Colors.blue[200],
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {},
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: Colors.white38,
                              border: Border.all(
                                color: Colors.blue[200],
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                this._overlayEntry.remove();
                                isOpen = false;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        // Stack(
        //   children: <Widget>[
        //     Align(
        //       alignment: Alignment.topCenter,
        //       child: Text(
        //         "displayDate",
        //         style: TextStyle(
        //             fontSize: 12, fontFamily: 'Garamond', color: Colors.white),
        //       ),
        //     ),
        //     Align(
        //       alignment: Alignment.center,
        //       child: CompositedTransformTarget(
        //         link: this._layerLink,
        //         child: IconButton(
        //           padding: EdgeInsets.symmetric(vertical: 1),
        //           iconSize: 35,
        //           onPressed: () {
        //             if (!isOpen) {
        //               this._overlayEntry = this._createOverlayEntry();
        //               Overlay.of(context).insert(this._overlayEntry);
        //             } else {
        //               this._overlayEntry.remove();
        //             }
        //             isOpen = !isOpen;
        //           },
        //           icon: Icon(Icons.more_horiz),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 10,
            decoration: BoxDecoration(
              color: Colors.white38,
              border: Border.all(
                color: Colors.blue[200],
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: Colors.white38,
            border: Border.all(
              color: Colors.blue[200],
            ),
          ),
          child: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {},
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: Colors.white38,
              border: Border.all(
                color: Colors.blue[200],
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                this._overlayEntry.remove();
                isOpen = false;
              },
            ),
          ),
        ),
      ],
      child: Padding(
        padding: EdgeInsets.all(3),
        child: Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                constraints: BoxConstraints(
                    minWidth: 20,
                    maxWidth: MediaQuery.of(context).size.width * .7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue[300],
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "text",
                  style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Garamond',
                      color: Colors.grey[850]),
                ),
              ),
              Container(
                color: Colors.blue,
                width: 50,
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:RLRank/providers/playersData.dart';
import 'package:RLRank/providers/trackerData.dart';
import 'package:RLRank/widgets/textWidgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerListDrawer extends StatelessWidget {
  const PlayerListDrawer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var prov = Provider.of<PlayersData>(context);
    List<Player> players = prov.data;
    var mq = MediaQuery.of(context);
    return Drawer(
      child: Container(
        color: AppColors.appBar,
        child: ListView(
          children: [
            SizedBox(height: mq.viewInsets.top),
            Container(
              height: 50,
              child: RaisedButton(
                color: Colors.grey[100],
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  Navigator.of(context).pushNamed("newPlayer");
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.group_add),
                    SizedBox(width: 10),
                    Text("Add new"),
                  ],
                ),
              ),
            ),
            ...players.map(
              (player) => GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Provider.of<TrackerData>(context, listen: false)
                      .setPlayer(player, context);
                },
                child: Container(
                  // decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(15),
                  // border: Border.all(color: Colors.grey[900], width: 1)),
                  margin: EdgeInsets.all(3),
                  child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                            placeholder: (c, a) => CircularProgressIndicator(),
                            imageUrl: player.picUrl),
                      ),
                      title: Text(player.handle),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.grey[100],
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                      backgroundColor: AppColors.appBar,
                                      title: Text(
                                        player.handle,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      content: Text(
                                          "Are you sure you want to delete player from the list?"),
                                      actions: [
                                        FlatButton(
                                            child: blueTitle("No"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            }),
                                        FlatButton(
                                            child: blueTitle("Yes"),
                                            onPressed: () async {
                                              await prov.removePlayer(player);
                                              if (prov.hasPlayers) {
                                                Provider.of<TrackerData>(
                                                        context,
                                                        listen: false)
                                                    .setPlayer(
                                                        prov.lastUsedPlayer,
                                                        context);
                                              }
                                              Navigator.of(context).pop();
                                            })
                                      ]));
                        },
                      )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

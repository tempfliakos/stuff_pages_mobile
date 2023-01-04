import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stuff_pages/enums/searchEnum.dart';
import 'package:stuff_pages/request/entities/achievement.dart';
import 'package:stuff_pages/request/entities/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'colorUtil.dart';

String pictureLink(String link) {
  return !link.startsWith("http") ? "https:" + link : link;
}

Widget getGame(Game game, Widget? trailing) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      ListTile(
        leading: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 44,
              minHeight: 44,
              maxWidth: 200,
              maxHeight: 200,
            ),
            child: img(game)),
        title: Text(game.title!, style: TextStyle(color: fontColor)),
        subtitle: calculatePercentageText(game),
        trailing: trailing,
      ),
    ],
  );
}

Widget img(Game game, [maxHeight = 100.0, maxWidth = 100.0]) {
  if (game.picture != null && game.picture != "null") {
    return ClipRRect(
      child: new ConstrainedBox(
        constraints: new BoxConstraints(
            minHeight: 5.0,
            minWidth: 5.0,
            maxHeight: maxHeight,
            maxWidth: maxWidth),
        child: Image.network(pictureLink(game.picture!),
            scale: 4, filterQuality: FilterQuality.low),
      ),
      borderRadius: BorderRadius.circular(8.0),
    );
  } else {
    return Image.asset('assets/images/default-movie-back.jpg', scale: 2.32);
  }
}

Widget achievementImg(Achievement achievement) {
  if (achievement.earned!) {
    if (achievement.picture != null && achievement.picture != "null") {
      return Image.network(achievement.picture!,
          filterQuality: FilterQuality.low, fit: BoxFit.cover);
    } else {
      return Image.asset('assets/images/default-movie-back.jpg');
    }
  } else {
    return SvgPicture.asset('assets/images/locked_trophy.svg');
  }
}

Widget trophyImg(Achievement achievement) {
  if (achievement.earned!) {
    if (achievement.picture != null && achievement.picture != "null") {
      if (achievement.picture!.startsWith("http")) {
        return Image.network(achievement.picture!,
            filterQuality: FilterQuality.low, fit: BoxFit.cover);
      } else {
        return Image.network("https:" + achievement.picture!,
            filterQuality: FilterQuality.low, fit: BoxFit.cover);
      }
    } else {
      return Image.asset('assets/images/default-movie-back.jpg');
    }
  } else {
    return SvgPicture.asset('assets/images/locked_trophy.svg');
  }
}

Widget highlightImg(game) {
  return Container(
    child: ClipRRect(
      child: img(game, 50.0, 50.0),
      borderRadius: BorderRadius.circular(8.0),
    ),
    padding: EdgeInsets.only(right: 10.0),
  );
}

Widget youtubeButton(game, achievement) {
  return IconButton(
      icon: FaIcon(FontAwesomeIcons.youtube, color: deleteColor,),
      onPressed: () {
        launchURL(game.title + " " + achievement.title, SearchEnum.youtube);
      });
}

Widget googleButton(game, achievement) {
  return IconButton(
      icon: FaIcon(FontAwesomeIcons.google, color: addedColor,),
      onPressed: () {
        launchURL(game.title + " " + achievement.title, SearchEnum.google);
      });
}

launchURL(destination, SearchEnum searchEnum) async {
  String url = searchEnum.url + destination;
  if (!await launch(url)) throw 'Could not launch $url';
}

Text? calculatePercentageText(Game game) {
  if (game.sum != null && game.sum != 0) {
    return Text(calculatePercentage(game), style: TextStyle(color: fontColor));
  }
  return null;
}

calculatePercentage(Game game) {
  double percentage = game.earned! / game.sum! * 100;
  return game.earned.toString() +
      "/" +
      game.sum.toString() +
      " (" +
      percentage.round().toString() +
      "%)";
}

List<Game> createFinalGameList(List<Game> games) {
  games.sort((a, b) => a.title!.compareTo(b.title!));
  return games;
}

import 'dart:typed_data';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stuff_pages/request/entities/achievement.dart';
import 'package:stuff_pages/request/entities/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stuff_pages/constants/searchConstants.dart';

import 'colorUtil.dart';

String pictureLink(String link) {
  return !link.startsWith("http") ? "https:" + link : link;
}

Widget getGame(BuildContext context, Game game, Widget? trailing) {
  Text? subtitle = calculatePercentageText(game);
  if(subtitle == null && game.console != null && game.subConsole != null) {
    subtitle = Text(game.console! + " " + game.subConsole!, style: TextStyle(color: fontColor));
  }
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
        subtitle: subtitle,
        trailing: trailing,
      ),
      getGameProgressionBar(context, game),
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
        child:
            Image.network(pictureLink(game.picture!),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low)
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
      icon: FaIcon(
        FontAwesomeIcons.youtube,
        color: deleteColor,
      ),
      onPressed: () {
        launchURL(game.title + " " + achievement.title, YOUTUBE);
      });
}

Widget googleButton(game, achievement) {
  return IconButton(
      icon: FaIcon(
        FontAwesomeIcons.google,
        color: addedColor,
      ),
      onPressed: () {
        launchURL(game.title + " " + achievement.title, GOOGLE);
      });
}

launchURL(destination, String requestedUrl) async {
  String url = requestedUrl + destination;
  if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication))
    throw 'Could not launch $url';
}

Text? calculatePercentageText(Game game) {
  if (!game.wish! && game.sum != null && game.sum != 0) {
    return Text(calculatePercentage(game), style: TextStyle(color: fontColor));
  }
  return null;
}

int getPercentage(Game game) {
  return (game.earned! / game.sum! * 100).round();
}

calculatePercentage(Game game) {
  return game.earned.toString() +
      "/" +
      game.sum.toString() +
      " (" +
      getPercentage(game).toString() +
      "%)";
}

List<Game> createFinalGameList(List<Game> games) {
  games.sort((a, b) =>
      removeDiacritics(a.title!).compareTo(removeDiacritics(b.title!)));
  return games;
}

Widget getGameProgressionBar(BuildContext context, Game game) {
  if (!game.wish! && (game.sum != null && game.sum != 0)) {
    double width = MediaQuery.of(context).size.width;
    int completePercentage = getPercentage(game);
    return Padding(
      padding: EdgeInsets.all(0.0),
      child: Align(
          alignment: FractionalOffset.centerLeft,
          child: Container(
            height: 5.0,
            width: width * (completePercentage / 100),
            color: getColorFromPercentage(completePercentage),
          )),
    );
  }
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 0.0),
    child: Container(height: 0, width: 0),
  );
}

Color getColorFromPercentage(int percentage) {
  if (percentage <= 33) {
    return deleteColor;
  } else if (percentage <= 66) {
    return futureColor;
  }
  return addedColor;
}

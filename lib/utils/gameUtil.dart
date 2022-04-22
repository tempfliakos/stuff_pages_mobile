import 'package:Stuff_Pages/request/entities/achievement.dart';
import 'package:Stuff_Pages/request/entities/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

String pictureLink(String link) {
  return !link.startsWith("http") ? "https:" + link : link;
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
        child: Image.network(pictureLink(game.picture),
            scale: 4, filterQuality: FilterQuality.low),
      ),
      borderRadius: BorderRadius.circular(8.0),
    );
  } else {
    return Image.asset('assets/images/default-movie-back.jpg', scale: 2.32);
  }
}

Widget achievementImg(Achievement achievement) {
  if (achievement.earned) {
    if (achievement.picture != null && achievement.picture != "null") {
      return Image.network(achievement.picture,
          filterQuality: FilterQuality.low, fit: BoxFit.cover);
    } else {
      return Image.asset('assets/images/default-movie-back.jpg');
    }
  } else {
    return SvgPicture.asset('assets/images/locked_trophy.svg');
  }
}

Widget trophyImg(Achievement achievement) {
  if (achievement.earned) {
    if (achievement.picture != null && achievement.picture != "null") {
      if (achievement.picture.startsWith("http")) {
        return Image.network(achievement.picture,
            filterQuality: FilterQuality.low, fit: BoxFit.cover);
      } else {
        return Image.network("https:" + achievement.picture,
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
      child: img(game, 50, 50),
      borderRadius: BorderRadius.circular(8.0),
    ),
    padding: EdgeInsets.only(right: 10.0),
  );
}

Widget addGameText(game) {
  return Text(
    game.title,
    textAlign: TextAlign.start,
    overflow: TextOverflow.ellipsis,
    textWidthBasis: TextWidthBasis.parent,
    maxLines: 10,
    style: TextStyle(
      fontSize: 16,
    ),
  );
}

launchURL(destination) async {
  var url = 'https://www.youtube.com/results?search_query=' + destination;
  if (!await launch(url)) throw 'Could not launch $url';
}

calculatePercentage(game) {
  if (game.sum == 0) {
    return "0/0";
  }
  return game.earned.toString() + "/" + game.sum.toString();
}

List<Game> createFinalGameList(List<Game> games) {
  List<Game> result = [];
  List<Game> starred = games.where((g) => g.star).toList();
  List<Game> notStarred = games.where((g) => !g.star).toList();
  starred.sort((a, b) => a.title.compareTo(b.title));
  notStarred.sort((a, b) => a.title.compareTo(b.title));
  result.addAll(starred);
  result.addAll(notStarred);
  return result;
}

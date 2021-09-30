import 'package:Stuff_Pages/request/entities/achievement.dart';
import 'package:Stuff_Pages/request/entities/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

Widget img(Game game) {
  if (game.picture != null && game.picture != "null") {
    return new ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: 5.0,
        minWidth: 5.0,
        maxHeight: 100.0,
        maxWidth: 100.0,
      ),
      child: Image.network("https:" + game.picture,
          scale: 4, filterQuality: FilterQuality.low),
    );
  } else {
    return Image.asset('assets/images/default-movie-back.jpg', scale: 2.32);
  }
}

Widget xboxImg(Game game) {
  if (game.picture != null && game.picture != "null") {
    return new ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: 5.0,
        minWidth: 5.0,
        maxHeight: 100.0,
        maxWidth: 100.0,
      ),
      child: Image.network(game.picture,
          scale: 4, filterQuality: FilterQuality.low),
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
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

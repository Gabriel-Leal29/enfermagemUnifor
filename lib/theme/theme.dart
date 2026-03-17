import 'dart:ui';

import 'package:flutter/material.dart';

class HexColor extends Color {
  HexColor(String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    var color = hexColor.toUpperCase().replaceAll("#", "");
    if (color.length == 6) {
      color = "FF$color";
    }
    return int.parse(color, radix: 16);
  }
}


// -------------- BACKGROUND ---------------//

Color azulUnifor = HexColor("#12253f");
Color azulUniforSelecionado = HexColor("#243B5A");
Color amareloUnifor = HexColor("#f9bb1f");
Color cinzaFundo = HexColor("#f2f4f7");

const Color menuItemNaoSelecionado = Color(0xFF8FA6C1);




// -------------- TEXTOS ---------------//

const textStyleGrayTitle = TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold);
// TODO: ALTERAR PARA A COR DEFINITIVA DO TITULO
const textStyleSubTituloAndMenuItem = TextStyle(color: menuItemNaoSelecionado, fontWeight: FontWeight.w400, fontSize: 14);
const textStyleMenuItemSelecionado = TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14);
const textStyleBlackTituloHeader = TextStyle(fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold);
const textStyleBlackTituloPage = TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold);
const textStyleBlackLabel =  TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold);
const textStyleSubTituloHeader = TextStyle(fontSize: 12, color: Color(0xFF757575));
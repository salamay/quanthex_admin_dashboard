import 'package:flutter/material.dart';

import '../../../presentation/pages/assets/select_reward_assets.dart';
import '../../domain/entities/supported_assets.dart';


class AssetUtils{


  static Future<SupportedCoin?> selectRewardAssets({required BuildContext context})async{
    SupportedCoin? coin=await  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      builder: (context) => SelectRewardAssets(),
    );
    return coin;
  }
}
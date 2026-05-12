import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/asset_controllers.dart';
import '../home/components/asset_item.dart';

// Receiver Modal
class SelectRewardAssets extends StatefulWidget {

  SelectRewardAssets({super.key,});

  @override
  State<SelectRewardAssets> createState() => _SelectRewardAssetsState();
}

class _SelectRewardAssetsState extends State<SelectRewardAssets> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Consumer<AssetController>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Select asset',
                    style: TextStyle(
                      color: const Color(0xFF2D2D2D),
                      fontSize: 20,
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                20.verticalSpace,
                Consumer<AssetController>(
                  builder: (context, assetCtr, child) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: assetCtr.assets.where((a)=>a.symbol.toLowerCase()=="doge"&&a.networkModel?.chainId==56).map((e){
                          return GestureDetector(
                              onTap: (){
                                context.pop(e);
                              },
                              child: AssetItem(coin: e)
                          );
                        }).toList()
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

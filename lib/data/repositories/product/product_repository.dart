import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_eco/utils/exceptions/firebase_exceptions.dart';
import 'package:firebase_eco/utils/exceptions/platform_exceptions.dart';
import 'package:firebase_eco/utils/helpers/firebase_storage_service.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../features/shop/models/product_model.dart';

class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final snapshot = await _db
          .collection('Products')
          .where('IsFeatured', isEqualTo: true)
          .limit(4)
          .get();

      return snapshot.docs.map((e) => ProductModel.fromSnapshot(e)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<void> uploadDummyData(List<ProductModel> products) async {
    try {
      final storage = Get.put(TFirebaseStorageService());

      for (var product in products) {
        // Upload thumbnail
        final thumbnail = await storage.getImageDataFromAssets(product.thumbnail);
        final thumbnailUrl = await storage.uploadImageData('Products/Images', thumbnail, product.thumbnail);
        product.thumbnail = thumbnailUrl;

        // Upload additional images if available
        if (product.images != null && product.images!.isNotEmpty) {
          List<String> imageUrl = [];
          for (var image in product.images!) {
            final assetImage = await storage.getImageDataFromAssets(image);
            final imageUrlItem = await storage.uploadImageData('Products/Images', assetImage, image);
            imageUrl.add(imageUrlItem);
          }
          product.images = imageUrl;
        }

        // Handle product variations
        if (product.productType == 'variable' && product.productVariations != null) {
          for (var variation in product.productVariations!) {
            final assetImage = await storage.getImageDataFromAssets(variation.image);
            final variationUrl = await storage.uploadImageData('Products/Images', assetImage, variation.image);
            variation.image = variationUrl;
          }
        }

        await _db.collection('Products').doc(product.id).set(product.toJson());
      }
    } on FirebaseException catch (e) {
      throw e.message!;
    } on SocketException catch (e) {
      throw e.message!;
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }


  Future<List<ProductModel>> getProductsForBrand({ required String brandId, int limit= -1}) async {
    try {
      final querySnapshot = limit == -1 ? await _db.collection('Products')
          .where("Brand.Id", isEqualTo: brandId)
          .get() :
      await _db.collection('Products')
          .where('Brand.Id', isEqualTo: brandId)
          .limit(limit)
          .get();

      final products = querySnapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
      return products;

    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }}
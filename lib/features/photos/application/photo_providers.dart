import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_providers.dart';
import '../domain/photo.dart';

final photoGalleryProvider = FutureProvider.autoDispose
    .family<PhotoGallery, PhotoOwner>((ref, owner) =>
        ref.watch(photoServiceProvider).repository.gallery(owner));

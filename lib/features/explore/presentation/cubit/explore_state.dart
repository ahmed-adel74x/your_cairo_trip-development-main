// lib/features/explore/presentation/cubit/explore_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/explore_place_model.dart';

abstract class ExploreState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExploreInitial extends ExploreState {}

class ExploreLoading extends ExploreState {}

class ExploreSuccess extends ExploreState {
  final List<ExplorePlaceModel> places;
  final String activeCategory; // 'all' | 'attraction' | 'restaurant' | 'hotel'

  ExploreSuccess({required this.places, this.activeCategory = 'all'});

  @override
  List<Object?> get props => [places, activeCategory];
}

class ExploreFailure extends ExploreState {
  final String message;

  ExploreFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ExploreFavouriteUpdated extends ExploreState {
  final int placeId;
  final bool isFavourite;

  ExploreFavouriteUpdated({required this.placeId, required this.isFavourite});

  @override
  List<Object?> get props => [placeId, isFavourite];
}

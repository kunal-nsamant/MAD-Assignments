// lib/util/stats.dart
import 'dart:math';

/// This class generates random numbers following an exponential distribution
/// Used for creating realistic random arrival times and service durations
class ExpDistribution {
  final double meanValue;
  final Random _randomNumberGenerator;
  
  ExpDistribution({required this.meanValue, int? seed}) : _randomNumberGenerator = Random(seed);
  
  // Generate the next random number from exponential distribution
  double next() {
    // Using the inverse transform method to convert uniform random to exponential
    // This is a standard mathematical technique for generating exponential random variables
    double uniformRandomNumber = _randomNumberGenerator.nextDouble();
    
    // Making sure that we don't get exactly 0, which would cause issues with the log function
    while (uniformRandomNumber == 0.0) {
      uniformRandomNumber = _randomNumberGenerator.nextDouble();
    }
    
    // Apply the inverse transform: -mean * ln(1 - U) where U is uniform random
    return -meanValue * log(1.0 - uniformRandomNumber);
  }
}
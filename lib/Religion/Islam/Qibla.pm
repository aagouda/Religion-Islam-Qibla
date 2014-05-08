#=Copyright Infomation
#==========================================================
#Module Name       : Religion::Islam::Qibla
#Program Author   : Dr. Ahmed Amin Elsheshtawy, Ph.D. Physics, E.E.
#Home Page           : http://www.islamware.com, http://www.mewsoft.com
#Contact Email      : support@islamware.com, support@mewsoft.com
#Copyrights © 2006-2013 IslamWare. All rights reserved.
#==========================================================
package Religion::Islam::Qibla;

use Carp;
use strict;
use warnings;

our $VERSION = '2.0';

use constant PI => 4 * atan2(1, 1);	#3.1415926535897932 PI=22/7, Pi = Atn(1) * 4
use constant DtoR => PI / 180;	# Degree to Radians
use constant RtoD => 180 / PI;	# Radians to Degrees
#==========================================================
#==========================================================
sub new {
my ($class, %args) = @_;
    
	my $self = bless {}, $class;
	# Default destination point is the  Kabah Lat=21 Deg N, Long 40 Deg E
	$self->{DestLat} = $args{DestLat}? $args{DestLat}: 21;
	$self->{DestLong} = $args{DestLong}? $args{DestLong}: 40;
    return $self;
}
#==========================================================
sub DestLat {
my ($self) = shift; 
	$self->{DestLat} = shift if @_;
	return $self->{DestLat};
}
#==========================================================
sub DestLong {
my ($self) = shift; 
	$self->{DestLong} = shift if @_;
	return $self->{DestLong};
}
#==========================================================
#Inverse Cosine, ArcCos
sub acos {
my ($self, $x) = @_; 
	return ($x<-1 or $x>1) ? undef : (atan2(sqrt(1-$x*$x),$x) ); 
}
#==========================================================
 #Converting from Degrees, Minutes and Seconds to Decimal Degrees
sub DegreeToDecimal {
my ($self, $degrees, $minutes, $seconds) = @_;
	return $degrees + ($minutes / 60) + ($seconds / 3600);
}
#==========================================================
#Converting from Decimal Degrees to Degrees, Minutes and Seconds
sub DecimalToDegree {
my ($self, $decimal_degree) = @_;
my ($degrees, $minutes, $seconds, $ff);
     
    $degrees = int($decimal_degree);
    $ff = $decimal_degree - $degrees;
    $minutes = int(60 * $ff);
    $seconds = 60 * ((60 * $ff) - $minutes);
	return ($degrees, $minutes, $seconds);
}
#==========================================================
# The shortest distance between points 1 and 2 on the earth's surface is
# d = arccos{cos(Dlat) - [1 - cos(Dlong)]cos(lat1)cos(lat2)}
# Dlat = lab - lat2
# Dlong = 10ng• - long2
# lati, = latitude of point i
# longi, = longitude of point i

#Conversion of grad to degrees is as follows:
#Grad=400-degrees/0.9 or Degrees=0.9x(400-Grad)

#Latitude is determined by the earth's polar axis. Longitude is determined
#by the earth's rotation. If you can see the stars and have a sextant and
#a good clock set to Greenwich time, you can find your latitude and longitude.

# one nautical mile equals to:
#   6076.10 feet
#   2027 yards
#   1.852 kilometers
#   1.151 statute mile

# Calculates the distance between any two points on the Earth
sub  GreatCircleDistance {
my ($self, $orig_lat , $dest_lat, $orig_long, $dest_long) = @_;
my ($d, $l1, $l2, $i1, $i2);
    
    $l1 = $orig_lat * DtoR;
    $l2 = $dest_lat * DtoR;
    $i1 = $orig_long * DtoR;
    $i2 = $dest_long * DtoR;
    
    $d = $self->acos(cos($l1 - $l2) - (1 - cos($i1 - $i2)) * cos($l1) * cos($l2));
    # One degree of such an arc on the earth's surface is 60 international nautical miles NM
    return $d * 60 * RtoD;
}
#==========================================================
#Calculates the direction from one point to another on the Earth
# a = arccos{[sin(lat2) - cos(d + lat1 - 1.5708)]/cos(lat1)/sin(d) + 1}
# Great Circle Bearing
sub GreatCircleDirection {
my ($self, $orig_lat, $dest_lat, $orig_long, $dest_long, $distance) = @_;
my ($a, $b, $d, $l1, $l2, $i1, $i2, $result, $dlong);
    
	$l1 = $orig_lat * DtoR;
	$l2 = $dest_lat * DtoR;
	$d = ($distance / 60) * DtoR; # divide by 60 for nautical miles NM to degree

	$i1 = $orig_long * DtoR;
	$i2 = $dest_long * DtoR;
	$dlong = $i1 - $i2;

	$a = sin($l2) - cos($d + $l1 - PI / 2);
	$b = $self->acos($a / (cos($l1) * sin($d)) + 1);

	#If (Abs(Dlong) < pi And Dlong < 0) Or (Abs(Dlong) > pi And Dlong > 0) Then
	#        Result = (2 * pi) - B
	#Else
	#        Result = B
	#End If

	$result = $b;
	return $result * RtoD;
}
#==========================================================
#The Equivalent Earth redius is 6,378.14 Kilometers.
# Calculates the direction of the Qibla from any point on
# the Earth From North Clocklwise
sub QiblaDirection {
my ($self, $orig_lat, $orig_long) = @_;
my ($distance, $bearing);
    
	# Kabah Lat=21 Deg N, Long 40 Deg E
	$distance = $self->GreatCircleDistance($orig_lat, $self->{DestLat}, $orig_long, $self->{DestLong});
	$bearing = $self->GreatCircleDirection($orig_lat, $self->{DestLat}, $orig_long, $self->{DestLong}, $distance);
	return $bearing;
}
#==========================================================
#==========================================================

1;

=head1 NAME

Religion::Islam::Qibla - Calculates the Muslim Qiblah Direction, Great Circle Distance, and Great Circle Direction

=head1 SYNOPSIS

	use Religion::Islam::Qibla;
	#create new object with default options, Destination point is Kabah Lat=21 Deg N, Long 40 Deg E
	my $qibla = Religion::Islam::Qibla->new();
	
	# OR
	#create new object and set your destination point Latitude and/or  Longitude
	my $qibla = Religion::Islam::Qibla->new(DestLat => 21, DestLong => 40);
	
	# Calculate the Qibla direction From North Clocklwise for Cairo : Lat=30.1, Long=31.3
	my $Latitude = 30.1;
	my $Longitude = 31.3;
	my $QiblaDirection = $qibla->QiblaDirection($Latitude, $Longitude);
	print "The Qibla Direction for $Latitude and $Longitude From North Clocklwise is: " . $QiblaDirection ."\n";
	
	# Calculates the distance between any two points on the Earth
	my $orig_lat = 31; my $dest_lat = 21; my $orig_long = 31.3; $dest_long = 40;
	my $distance = $qibla->GreatCircleDistance($orig_lat , $dest_lat, $orig_long, $dest_long);
	print "The distance is: $distance \n";

	# Calculates the direction from one point to another on the Earth. Great Circle Bearing
	my $direction = $qibla->GreatCircleDirection($orig_lat, $dest_lat, $orig_long, $dest_long, $distance);
	print "The direction is: $direction \n";
	
	# You can get and set the distination point Latitude and Longitude
	# $qibla->DestLat(21);		#	set distination Latitude
	# $qibla->DestLong(40);	# set distincatin Longitude
	print "Destination Latitude:" . $qibla->DestLat();
	print "Destination Longitude:" . $qibla->DestLong();

=head1 DESCRIPTION

This module calculates the Qibla direction where muslim prayers directs their face. It 
also calculates and uses the Great Circle Distance and Great Circle Direction.

=head1 SEE ALSO

L<Date::HijriDate>
L<Religion::Islam::Quran>
L<Religion::Islam::PrayTime>
L<Religion::Islam::PrayerTimes>

=head1 AUTHOR

Ahmed Amin Elsheshtawy,  <support@islamware.com> <support@mewsoft.com>
Website: http://www.islamware.com   http://www.mewsoft.com

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2013 by Ahmed Amin Elsheshtawy support@islamware.com, support@mewsoft.com
L<http://www.islamware.com>  L<http://www.mewsoft.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

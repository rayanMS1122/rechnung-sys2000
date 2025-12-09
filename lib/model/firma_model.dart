import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// --- Modelle ---

class Firma {
  String name;
  String strasse;
  String plz;
  String ort;
  String telefon;
  String email;
  String website;

  Firma({
    required this.name,
    required this.strasse,
    required this.plz,
    required this.ort,
    required this.telefon,
    required this.email,
    required this.website,
  });

  factory Firma.fromJson(Map<String, dynamic> json) => Firma(
        name: json['name'] ?? '',
        strasse: json['strasse'] ?? '',
        plz: json['plz'] ?? '',
        ort: json['ort'] ?? '',
        telefon: json['telefon'] ?? '',
        email: json['email'] ?? '',
        website: json['website'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'strasse': strasse,
        'plz': plz,
        'ort': ort,
        'telefon': telefon,
        'email': email,
        'website': website,
      };
}

class Kunde {
  String name;
  String strasse;
  String plz;
  String ort;
  String telefon;
  String email;

  Kunde({
    required this.name,
    required this.strasse,
    required this.plz,
    required this.ort,
    required this.telefon,
    required this.email,
  });

  factory Kunde.fromJson(Map<String, dynamic> json) => Kunde(
        name: json['name'] ?? '',
        strasse: json['strasse'] ?? '',
        plz: json['plz'] ?? '',
        ort: json['ort'] ?? '',
        telefon: json['telefon'] ?? '',
        email: json['email'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'strasse': strasse,
        'plz': plz,
        'ort': ort,
        'telefon': telefon,
        'email': email,
      };
}

class Monteur {
  String vorname;
  String nachname;
  String telefon;
  String email;

  Monteur({
    required this.vorname,
    required this.nachname,
    required this.telefon,
    this.email = '',
  });

  // Voller Name als Getter (praktisch für Anzeige)
  String get vollerName => '$vorname $nachname'.trim();

  factory Monteur.fromJson(Map<String, dynamic> json) => Monteur(
        vorname: json['vorname'] ?? '',
        nachname: json['nachname'] ?? '',
        telefon: json['telefon'] ?? '',
        email: json['email'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'vorname': vorname,
        'nachname': nachname,
        'telefon': telefon,
        'email': email,
      };
}

class Baustelle {
  String strasse;
  String plz;
  String ort;

  Baustelle({
    required this.strasse,
    required this.plz,
    required this.ort,
  });

  factory Baustelle.fromJson(Map<String, dynamic> json) => Baustelle(
        strasse: json['strasse'] ?? '',
        plz: json['plz'] ?? '',
        ort: json['ort'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'strasse': strasse,
        'plz': plz,
        'ort': ort,
      };
}

class CompanyData {
  Firma firma;
  Kunde? kunde; // optional
  Monteur? monteur; // neu: Monteur ist jetzt auch dabei
  Baustelle baustelle;

  CompanyData({
    required this.firma,
    this.kunde,
    this.monteur, // kann null sein, falls noch keiner ausgewählt
    required this.baustelle,
  });

  factory CompanyData.fromJson(Map<String, dynamic> json) => CompanyData(
        firma: Firma.fromJson(json['firma'] ?? {}),
        kunde: json['kunde'] != null ? Kunde.fromJson(json['kunde']) : null,
        monteur:
            json['monteur'] != null ? Monteur.fromJson(json['monteur']) : null,
        baustelle: Baustelle.fromJson(json['baustelle'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'firma': firma.toJson(),
        if (kunde != null) 'kunde': kunde!.toJson(),
        if (monteur != null) 'monteur': monteur!.toJson(),
        'baustelle': baustelle.toJson(),
      };
}

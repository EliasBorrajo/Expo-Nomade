// Dummy data
import 'dart:ui';

import 'package:latlong2/latlong.dart';

import '../dataModels/Migration.dart';
import '../dataModels/Museum.dart';
import '../dataModels/MuseumObject.dart';
import '../dataModels/filters_tags.dart';
import '../dataModels/question_models.dart';

final dummyObjects = {
  MuseumObject(
    id: '1',
    museumName: 'Museum 1',
    name: 'Object 1',
    description: 'Description of Object 1',
    point: const LatLng( 0.2, 0.2),
  ),
  MuseumObject(
    id: '2',
    museumName: 'Museum 1',
    name: 'Object 2',
    description: 'Description of Object 2',
    point: const LatLng( 0.2, 0.2),
  ),
  MuseumObject(
    id: '3',
    museumName: 'Museum 2',
    name: 'Object 3',
    description: 'Description of Object 3',
    point: const LatLng( 0.2, 0.2),
  )

};

final dummyMuseums = [
  Museum(
    id: '1',
    name: 'Museum 1',
    address: const LatLng(-12.34, 110.89),
    website: 'Website 1',
  ),
  Museum(
    id: '2',
    name: 'Museum 2',
    address:  const LatLng( 89,  100.89),
    website: 'Website 2',

  ),
  Museum(
    id: '3',
    name: 'Museum 3',
    address: const LatLng( -89,  170.89),
    website: 'Website 3',
  ),
  Museum(
    id: '4',
    name: 'Museum 4',
    address: const LatLng( 77.2,  160.89),
    website: 'Website 4',
  ),
];

final dummyFilters = [
  FilterTag(
    id: 1,
    typeName: "Chronologie",
    options: [
      "Préhistoire",
      "Antiquité",
      "Moyen Age",
      "Temps modernes",
      "Epoque contemporaine"
    ]
  ),
  FilterTag(
      id: 2,
      typeName: "Raison de migration",
      options: [
        "Recherche de meilleures terres",
        "Fuite",
        "Travail",
        "Établissement",
        "Influence",
        "Conquête",
        "Domination",
        "Refuge",
        "Art"
      ]
  ),
  FilterTag(
      id: 3,
      typeName: "Musées",
      options: [
        "Liste des musées"
      ]
  ),
  FilterTag(
      id: 4,
      typeName: "Population",
      options: [
        "Francs",
        "Allemands",
        "Italiens",
        "Belges",
        "Ottomans"
      ]
  ),
  FilterTag(
      id: 5,
      typeName: "Oeuvres d'art",
      options: [
        "Peinture",
        "Sculptures",
        "Dessins",
        "Gravures",
        "Photographie"
      ]
  ),
  FilterTag(
      id: 6,
      typeName: "Antiquités",
      options: [
        "Poterie",
        "Céramiques",
        "Objets en bronze"
      ]
  ),
  FilterTag(
      id: 7,
      typeName: "Artisanat",
      options: [
        "Tapisserie",
        "Bijoux",
        "Poterie décorative"
      ]
  ),
];

final dummyQuiz = [
  Question(
    id: '1',
    questionText: 'Quelle planète est connue comme la "planète rouge" ?',
    answers: [
      'Vénus', 'Mars', 'Saturne',
    ],
    correctAnswer: 1,
  ),
  Question(
    id: '2',
    questionText: 'Quel est l\'élément chimique symbolisé par "H" ?',
    answers: [
      'Hélium', 'Hydrogène','Carbone',
    ],
    correctAnswer: 1,
  ),
  Question(
    id: '3',
    questionText: 'Combien de continents y a-t-il sur Terre ?',
    answers: [
      '4', '6', '7',
    ],
    correctAnswer: 2,
  ),
  Question(
    id: '4',
    questionText: 'Quelle est la capitale de la France ?',
    answers: [
      'Berlin', 'Madrid', 'Paris',
    ],
    correctAnswer: 2,
  ),
  Question(
    id: '5',
    questionText: 'Quel est le plus grand animal terrestre ?',
    answers: [
      'Éléphant', 'Girafe', 'Lion',
    ],
    correctAnswer: 0,
  ),
  Question(
    id: '6',
    questionText: 'Quel est le plus petit État du monde ?',
    answers: [
      'Vatican', 'Andorre', 'Malte',
    ],
    correctAnswer: 0,
  ),
  Question(
    id: '7',
    questionText: 'Quelle est la distance approximative de la Terre à la Lune ?',
    answers: [
      '100 000 km', '384 400 km', '500 000 km',
    ],
    correctAnswer: 1,
  ),
  Question(
    id: '8',
    questionText: 'Qui a peint la Joconde ?',
    answers: [
      'Vincent van Gogh', 'Leonardo da Vinci', 'Michel-Ange',
    ],
    correctAnswer: 1,
  ),
  Question(
    id: '9',
    questionText: 'Quel est le symbole chimique de l\'or ?',
    answers: [
      'Ag', 'Au', 'Cu',
    ],
    correctAnswer: 1,
  ),
  Question(
    id: '10',
    questionText: 'Quel est le plus grand océan sur Terre ?',
    answers: [
      'Océan Atlantique', 'Océan Indien', 'Océan Pacifique',
    ],
    correctAnswer: 2,
  ),
  Question(
    id: '11',
    questionText: 'Quel est le plus grand désert du monde ?',
    answers: [
      'Désert du Sahara', 'Désert de Mojave', 'Désert du Kalahari',
    ],
    correctAnswer: 0,
  ),
  Question(
    id: '12',
    questionText: 'Quel est le plus haut sommet du monde ?',
    answers: [
      'Mont Kilimandjaro', 'Mont Everest', 'Mont McKinley',
    ],
    correctAnswer: 1,
  ),
  Question(
    id: '13',
    questionText: 'Quel est le plus grand fleuve du monde ?',
    answers: [
      'Fleuve Amazone', 'Fleuve Nil', 'Fleuve Yangtsé',
    ],
    correctAnswer: 0,
  ),
  Question(
    id: '14',
    questionText: 'Quel est l\'instrument de musique à cordes le plus grand ?',
    answers: [
      'Violon','Contrebasse','Guitare',
    ],
    correctAnswer: 1,
  ),
  Question(
    id: '15',
    questionText: 'Quelle est la plus grande mer du monde ?',
    answers: [
      'Mer Méditerranée', 'Mer Rouge', 'Mer Caspienne',
    ],
    correctAnswer: 2,
  ),
];

final dummyMigrations = [
  Migration(
    id: '1',
    name: 'Migration 1',
    description: 'Description of Migration 1',
    arrival: 'Arrival 1',
    polygons: [
      MigrationSource(
        name: 'source 1',
        points:
        [const LatLng(46.23, 7.30), const LatLng(46.25, 7.30), const LatLng(46.25, 7.32), const LatLng(46.25, 7.6)],
      ),
    ],
    images: ['image1.jpg', 'image2.jpg'],
  ),
  Migration(
    id: '2',
    name: 'Migration 2',
    description: 'Description of Migration 2',
    arrival: 'Arrival 2',
    polygons: [
      MigrationSource(
        name: 'source 2',
        points:
        [const LatLng(46.23, 7.60), const LatLng(46.25, 7.60), const LatLng(46.25, 7.62), const LatLng(46.25, 7.90)],

      ),
    ],
  ),
];
// Dummy data
import 'dart:ui';

import 'package:latlong2/latlong.dart';

import '../dataModels/Migration.dart';
import '../dataModels/Museum.dart';
import '../dataModels/MuseumObject.dart';

final dummyMuseums = [
  Museum(
    id: '1',
    name: 'Museum 1',
    address: const LatLng(-12.34, 110.89),
    website: 'Website 1',
    objects: [
      MuseumObject(
        id: 'obj000',
        name: 'Object 1',
        description: 'Description of Object 1',
        point: const LatLng( 0.2, 0.2),
      ),
      MuseumObject(
        id: 'obj001',
        name: 'Object 2',
        description: 'Description of Object 2',
        point: const LatLng( 0.2, 0.2),
      ),
    ],
  ),
  Museum(
    id: '2',
    name: 'Museum 2',
    address:  const LatLng( 89,  100.89),
    website: 'Website 2',
    objects: [
      MuseumObject(
        id: 'obj001',
        name: 'Object 2',
        description: 'Description of Object 2',
        point: const LatLng( 0.2, 0.2),
      ),
    ],
  ),
  Museum(
    id: '3',
    name: 'Museum 3',
    address: const LatLng( -89,  170.89),
    website: 'Website 3',
    objects: null, // No objects for this museum
  ),
  Museum(
    id: '4',
    name: 'Museum 4',
    address: const LatLng( 77.2,  160.89),
    website: 'Website 4',
    objects: const <MuseumObject>[], // Empty list of objects for this museum // TODO : supprimer ? Ne peut pas arriver je crois
  ),
];

/*final dummyQuiz = [
  Question(
    id: '1',
    questionText: 'Quelle planète est connue comme la "planète rouge" ?',
    answers: [
      Answer(answerText: 'Vénus'),
      Answer(answerText: 'Mars'),
      Answer(answerText: 'Saturne'),
    ],
    correctAnswer: 1,
  ),
  Question(
    id: '2',
    questionText: 'Quel est l\'élément chimique symbolisé par "H" ?',
    answers: [
      Answer(answerText: 'Hélium'),
      Answer(answerText: 'Hydrogène'),
      Answer(answerText: 'Carbone'),
    ],
    correctAnswer: 1,
  ),
  Question(
    id: '3',
    questionText: 'Combien de continents y a-t-il sur Terre ?',
    answers: [
      Answer(answerText: '4'),
      Answer(answerText: '6'),
      Answer(answerText: '7'),
    ],
    correctAnswer: 2,
  ),
  Question(
    id: '4',
    questionText: 'Quelle est la capitale de la France ?',
    answers: [
      Answer(answerText: 'Berlin'),
      Answer(answerText: 'Madrid'),
      Answer(answerText: 'Paris'),
    ],
    correctAnswer: 2,
  ),
  Question(
    id: '5',
    questionText: 'Quel est le plus grand animal terrestre ?',
    answers: [
      Answer(answerText: 'Éléphant'),
      Answer(answerText: 'Girafe'),
      Answer(answerText: 'Lion'),
    ],
    correctAnswer: 0,
  ),
  Question(
    id: '6',
    questionText: 'Quel est le plus petit État du monde ?',
    answers: [
      Answer(answerText: 'Vatican'),
      Answer(answerText: 'Andorre'),
      Answer(answerText: 'Malte'),
    ],
    correctAnswer: 0,
  ),
  Question(
    id: '7',
    questionText: 'Quelle est la distance approximative de la Terre à la Lune ?',
    answers: [
      Answer(answerText: '100 000 km'),
      Answer(answerText: '384 400 km'),
      Answer(answerText: '500 000 km'),
    ],
    correctAnswer: 1,
  ),
  Question(
    id: '8',
    questionText: 'Qui a peint la Joconde ?',
    answers: [
      Answer(answerText: 'Vincent van Gogh'),
      Answer(answerText: 'Leonardo da Vinci'),
      Answer(answerText: 'Michel-Ange'),
    ],
    correctAnswer: 1,
  ),
  Question(
    id: '9',
    questionText: 'Quel est le symbole chimique de l\'or ?',
    answers: [
      Answer(answerText: 'Ag'),
      Answer(answerText: 'Au'),
      Answer(answerText: 'Cu'),
    ],
    correctAnswer: 1,
  ),
  Question(
    id: '10',
    questionText: 'Quel est le plus grand océan sur Terre ?',
    answers: [
      Answer(answerText: 'Océan Atlantique'),
      Answer(answerText: 'Océan Indien'),
      Answer(answerText: 'Océan Pacifique'),
    ],
    correctAnswer: 2,
  ),
  Question(
    id: '11',
    questionText: 'Quel est le plus grand désert du monde ?',
    answers: [
      Answer(answerText: 'Désert du Sahara'),
      Answer(answerText: 'Désert de Mojave'),
      Answer(answerText: 'Désert du Kalahari'),
    ],
    correctAnswer: 0,
  ),
  Question(
    id: '12',
    questionText: 'Quel est le plus haut sommet du monde ?',
    answers: [
      Answer(answerText: 'Mont Kilimandjaro'),
      Answer(answerText: 'Mont Everest'),
      Answer(answerText: 'Mont McKinley'),
    ],
    correctAnswer: 1,
  ),
  Question(
    id: '13',
    questionText: 'Quel est le plus grand fleuve du monde ?',
    answers: [
      Answer(answerText: 'Fleuve Amazone'),
      Answer(answerText: 'Fleuve Nil'),
      Answer(answerText: 'Fleuve Yangtsé'),
    ],
    correctAnswer: 0,
  ),
  Question(
    id: '14',
    questionText: 'Quel est l\'instrument de musique à cordes le plus grand ?',
    answers: [
      Answer(answerText: 'Violon'),
      Answer(answerText: 'Contrebasse'),
      Answer(answerText: 'Guitare'),
    ],
    correctAnswer: 1,
  ),
  Question(
    id: '15',
    questionText: 'Quelle est la plus grande mer du monde ?',
    answers: [
      Answer(answerText: 'Mer Méditerranée'),
      Answer(answerText: 'Mer Rouge'),
      Answer(answerText: 'Mer Caspienne'),
    ],
    correctAnswer: 2,
  ),
];*/

final dummyMigrations = [
  Migration(
    name: 'Migration 1',
    description: 'Description of Migration 1',
    arrival: 'Arrival 1',
    polygons: [
      MigrationSource(
        [LatLng(0, 0), LatLng(0, 10), LatLng(10, 10)],
        Color(0xFF00FF00), 'source 1',
      ),
    ],
    images: ['image1.jpg', 'image2.jpg'],
  ),
  Migration(
    name: 'Migration 2',
    description: 'Description of Migration 2',
    arrival: 'Arrival 2',
    polygons: [
      MigrationSource(
        [LatLng(20, 20), LatLng(30, 20), LatLng(30, 30)],
        Color(0xFFFF0000), 'source 2',
      ),
      MigrationSource(
        [LatLng(40, 40), LatLng(40, 50), LatLng(50, 50)],
        Color(0xFF0000FF), 'source 2.1',
      ),
    ],
  ),
];
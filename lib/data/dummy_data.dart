import 'package:flutter/material.dart';

class StoryData {
  final String title;
  final String image;
  final List<String> pages;

  StoryData({
    required this.title,
    required this.image,
    required this.pages,
  });
}

// ================= STORY =================
final List<StoryData> stories = [
  StoryData(
    title: "Timun Mas",
    image: "assets/images/timun_mas.jpg",
    pages: [
  "Once upon a time, there lived a kind farmer in a small village. She felt very lonely because she had no children. Every day, she prayed and hoped to have a child who could keep her company. One morning, she found a golden cucumber in her garden, and inside it was a beautiful baby girl. She named the child Timun Mas and loved her very much.",

  "Years later, a giant named Buto Ijo came to the farmer’s house. He said that he had given the golden cucumber and asked the farmer to give Timun Mas to him when she grew up. The farmer was afraid but agreed because she had no choice. However, deep in her heart, she did not want to lose her beloved daughter.",

  "When Timun Mas became a brave and smart young girl, the farmer told her the truth about the giant. She gave Timun Mas some magical items to protect herself: cucumber seeds, needles, salt, and shrimp paste. Timun Mas promised to be careful and prepared to face the danger.",

  "One day, the giant came to take Timun Mas away. Timun Mas ran as fast as she could while the giant chased her. She threw the magical items one by one. The cucumber seeds became a big jungle, the needles turned into sharp bamboo trees, the salt became a wide sea, and the shrimp paste turned into hot mud that trapped the giant.",

  "Finally, the giant was defeated and could not chase Timun Mas anymore. Timun Mas returned home safely to her mother. They hugged each other happily and lived peacefully together in the village. From that day on, Timun Mas was known as a brave and clever girl.",
],
  ),


  StoryData(
    title: "Malin Kundang",
    image: "assets/images/malin_kundang.jpg",
    pages: [
    "Long ago, in a small village near the beach, lived a boy named Malin Kundang with his mother. They were very poor, but his mother always loved him deeply. She worked hard every day to take care of Malin and taught him to be kind and respectful.",

    "When Malin grew older, he dreamed of becoming a successful man. He decided to leave the village and sail across the sea to find a better life. His mother felt sad but supported his decision. Before Malin left, she hugged him tightly and prayed for his safety every day.",

    "After many years, Malin became a rich merchant with a big ship and a beautiful wife. One day, his ship stopped near his old village. His mother heard the news and happily came to meet him. She was very excited to see her beloved son again.",

    "However, Malin was ashamed of his poor mother in front of his wife and crew. He pretended not to know her and spoke harshly to her. His mother felt heartbroken and cried sadly. With deep pain in her heart, she prayed for justice because her son had forgotten her.",

    "Suddenly, dark clouds filled the sky and a strong storm came. Malin’s ship was shaken by big waves. In the end, Malin was turned into stone as a punishment for his behavior. The villagers believed that this was a lesson to always respect and love our parents.",
    ],
  ),

  StoryData(
  title: "Roro Jonggrang",
  image: "assets/images/roro_jonggrang.jpg",
  pages: [
    "Long ago, there was a beautiful princess named Roro Jonggrang. She lived in a great kingdom with her father, the king. Many people admired her beauty and kindness, and the palace was always full of life.",

    "One day, a powerful prince named Bandung Bondowoso attacked the kingdom. He defeated the king and wanted to marry Princess Roro Jonggrang. The princess felt scared and did not want to marry him.",

    "To avoid the marriage, Roro Jonggrang gave the prince a very difficult challenge. She asked him to build one thousand temples in just one night. She believed it was impossible.",

    "Surprisingly, Bandung Bondowoso used magic and almost completed the temples. Roro Jonggrang became worried and asked the villagers to trick the spirits by making morning sounds.",

    "Because of the trick, the prince failed to finish the last temple. He became very angry and turned Roro Jonggrang into a stone statue. People believe she became the final statue in the temple.",
  ],
),

StoryData(
  title: "Keong Mas",
  image: "assets/images/keong_mas.jpg",
  pages: [
    "Once upon a time, there lived a kind princess in a beautiful kingdom. Everyone loved her because she was gentle, helpful, and always polite to others.",

    "However, her kindness made another princess jealous. The jealous princess used magic to turn her into a golden snail and threw her far away from the palace.",

    "A poor old woman found the golden snail near the river and took it home. She was surprised when delicious food always appeared in her house every day.",

    "One day, the old woman discovered that the golden snail was actually a beautiful princess. The spell was broken because of kindness and true friendship.",

    "In the end, the princess returned to the palace and lived happily again. The story teaches us that kindness will always bring good things.",
  ],
),

StoryData(
  title: "Jaka Tarub",
  image: "assets/images/jaka_tarub.jpg",
  pages: [
    "Jaka Tarub was a kind young man who lived near a forest. He enjoyed walking in nature and loved spending time near rivers and waterfalls.",

    "One day, he saw seven beautiful angels bathing in a hidden lake. He was amazed by their beauty and quietly watched from behind the trees.",

    "Jaka Tarub hid one of the angel’s scarves. Without her scarf, the angel could not return to heaven and stayed on earth with Jaka Tarub.",

    "They later got married and lived happily together. However, the angel always felt something was missing in her life.",

    "When she finally found her hidden scarf, she was able to return to heaven. Jaka Tarub felt sad, but he learned an important lesson about honesty.",
  ],
),

];

// ================= QUIZ =================
final Map<String, List<Map<String, dynamic>>> quizData = {
  "Timun Mas": [
    {
      "question": "Who is the main character?",
      "options": ["Malin", "Timun Mas", "Buto Ijo", "Mother"],
      "answer": 1,
    },
    {
      "question": "Who chased Timun Mas?",
      "options": ["King", "Buto Ijo", "Dragon", "Farmer"],
      "answer": 1,
    },
    {
      "question": "What did Timun Mas use to escape?",
      "options": ["Magic items", "Boat", "Horse", "Sword"],
      "answer": 0,
    },
    {
      "question": "Timun Mas is ...",
      "options": ["Lazy", "Brave", "Evil", "Greedy"],
      "answer": 1,
    },
    {
      "question": "How did the story end?",
      "options": ["Sad", "Happy", "Angry", "Lost"],
      "answer": 1,
    },
  ],

  "Malin Kundang": [
    {
      "question": "Who is Malin?",
      "options": ["Farmer", "Sailor", "King", "Giant"],
      "answer": 1,
    },
    {
      "question": "Who cursed Malin?",
      "options": ["Father", "Teacher", "Mother", "Friend"],
      "answer": 2,
    },
    {
      "question": "Why was Malin cursed?",
      "options": ["Lazy", "Forgot mother", "Angry", "Poor"],
      "answer": 1,
    },
    {
      "question": "What happened to Malin?",
      "options": ["Ran away", "Cried", "Turned to stone", "Fell asleep"],
      "answer": 2,
    },
    {
      "question": "Moral lesson?",
      "options": ["Be rich", "Be brave", "Respect parents", "Travel far"],
      "answer": 2,
    },
  ],
    "Roro Jonggrang": [
    {
      "question": "Who is Roro Jonggrang?",
      "options": ["A farmer", "A princess", "A giant", "A sailor"],
      "answer": 1,
    },
    {
      "question": "Who wanted to marry Roro Jonggrang?",
      "options": ["The king", "Her father", "Bandung Bondowoso", "Malin"],
      "answer": 2,
    },
    {
      "question": "What challenge did she give?",
      "options": ["Build a house", "Find treasure", "Build 1000 temples", "Catch a dragon"],
      "answer": 2,
    },
    {
      "question": "Why did the prince fail?",
      "options": ["He was lazy", "He was sick", "She tricked him", "He forgot"],
      "answer": 2,
    },
    {
      "question": "What happened to Roro Jonggrang?",
      "options": ["She left", "She became a queen", "She turned into stone", "She ran away"],
      "answer": 2,
    },
  ],

  "Keong Mas": [
    {
      "question": "Who was turned into a golden snail?",
      "options": ["Old woman", "Princess", "Queen", "Witch"],
      "answer": 1,
    },
    {
      "question": "Why was she cursed?",
      "options": ["She was lazy", "She was kind", "Another princess was jealous", "She was rich"],
      "answer": 2,
    },
    {
      "question": "Who helped the golden snail?",
      "options": ["A king", "A soldier", "An old woman", "A prince"],
      "answer": 2,
    },
    {
      "question": "What lesson does the story teach?",
      "options": ["Be rich", "Be kind", "Be famous", "Be strong"],
      "answer": 1,
    },
    {
      "question": "How did the story end?",
      "options": ["Sadly", "With anger", "Happily", "With fear"],
      "answer": 2,
    },
  ],

  "Jaka Tarub": [
    {
      "question": "Where did Jaka Tarub meet the angels?",
      "options": ["Market", "River", "Forest lake", "Village"],
      "answer": 2,
    },
    {
      "question": "What did Jaka Tarub hide?",
      "options": ["A ring", "A crown", "A scarf", "A sword"],
      "answer": 2,
    },
    {
      "question": "Why could the angel not return to heaven?",
      "options": ["She was sick", "She lost her scarf", "She was tired", "She was angry"],
      "answer": 1,
    },
    {
      "question": "How did the angel finally return?",
      "options": ["She flew", "She found her scarf", "She ran", "She cried"],
      "answer": 1,
    },
    {
      "question": "What lesson does the story teach?",
      "options": ["Be rich", "Be honest", "Be proud", "Be fast"],
      "answer": 1,
    },
  ],

};

// ================= DRAG MATCH =================
final Map<String, Map<String, IconData>> dragMatchData = {
  "Timun Mas": {
    "Timun Mas": Icons.girl,
    "Buto Ijo": Icons.person,
    "Mother": Icons.woman,
    "Farmer": Icons.agriculture,
    "Village": Icons.home,
  },
  "Malin Kundang": {
    "Malin": Icons.person,
    "Mother": Icons.woman,
    "Ship": Icons.directions_boat,
    "Stone": Icons.landscape,
    "Village": Icons.home,
  },
    "Roro Jonggrang": {
    "Roro Jonggrang": Icons.girl,
    "Bandung": Icons.person,
    "Temple": Icons.account_balance,
    "Kingdom": Icons.castle,
    "Stone": Icons.landscape,
  },

  "Keong Mas": {
    "Princess": Icons.girl,
    "Snail": Icons.bug_report,
    "Old Woman": Icons.woman,
    "Magic": Icons.auto_fix_high,
    "Palace": Icons.castle,
  },

  "Jaka Tarub": {
    "Jaka Tarub": Icons.person,
    "Angel": Icons.self_improvement,
    "Scarf": Icons.checkroom,
    "Forest": Icons.park,
    "Lake": Icons.water,
  },

};

// ================= GUESS WORD =================
final Map<String, List<Map<String, String>>> guessWordData = {
  "Timun Mas": [
    {"clue": "Giant name", "answer": "BUTO"},
    {"clue": "Main character", "answer": "TIMUN"},
    {"clue": "Mother role", "answer": "IBU"},
    {"clue": "Place to live", "answer": "DESA"},
    {"clue": "Story ending", "answer": "HAPPY"},
  ],
  "Malin Kundang": [
    {"clue": "Main character", "answer": "MALIN"},
    {"clue": "Who cursed Malin?", "answer": "IBU"},
    {"clue": "Transportation", "answer": "KAPAL"},
    {"clue": "Malin turned to", "answer": "BATU"},
    {"clue": "Moral value", "answer": "HORMAT"},
  ],
    "Roro Jonggrang": [
    {"clue": "Princess name", "answer": "RORO"},
    {"clue": "Prince name", "answer": "BANDUNG"},
    {"clue": "Built many temples", "answer": "TEMPLE"},
    {"clue": "She turned into", "answer": "STONE"},
    {"clue": "Place of story", "answer": "KINGDOM"},
  ],

  "Keong Mas": [
    {"clue": "Golden animal", "answer": "SNAIL"},
    {"clue": "Main character", "answer": "PRINCESS"},
    {"clue": "Old helper", "answer": "GRANDMA"},
    {"clue": "Story magic", "answer": "MAGIC"},
    {"clue": "Happy ending place", "answer": "PALACE"},
  ],

  "Jaka Tarub": [
    {"clue": "Main character", "answer": "JAKA"},
    {"clue": "Girl from heaven", "answer": "ANGEL"},
    {"clue": "Hidden object", "answer": "SCARF"},
    {"clue": "Story place", "answer": "FOREST"},
    {"clue": "Where angels bathe", "answer": "LAKE"},
  ],

};

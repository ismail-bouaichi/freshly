import '../core/produce.dart';
import '../core/theme.dart';
import 'models.dart';

/// Sample catalog. Swap for your API later — screens only read [Catalog].
abstract final class Catalog {
  static const strawberries = Product(
    id: 'strawberries',
    name: 'Strawberries',
    unit: '250 g · Organic',
    price: 3.49,
    oldPrice: 4.20,
    art: Produce.strawberry,
    tint: AppColors.tintBerry,
    categories: {Category.fruits},
    tags: {Tag.organic, Tag.seasonal, Tag.sale},
    rating: 4.9,
    reviews: '2.3k',
    kcal: 32,
    water: '91%',
    vitamin: 'Vit C',
    description:
        'Sun-ripened, hand-picked berries from family farms. Sweet, juicy and fragrant — perfect for smoothies, desserts or snacking straight from the punnet.',
    keywords: ['berry', 'berries', 'red', 'fruit', 'smoothie'],
    popularity: 99,
  );
  static const avocado = Product(
    id: 'avocado',
    name: 'Hass Avocado',
    unit: '2 pcs · Ready to eat',
    price: 2.99,
    art: Produce.avocado,
    tint: AppColors.tintLime,
    categories: {Category.fruits, Category.exotic},
    tags: {Tag.organic},
    rating: 4.8,
    reviews: '1.8k',
    kcal: 160,
    water: '73%',
    vitamin: 'Vit K',
    description: 'Creamy, buttery Hass avocados picked at peak ripeness. Ready to smash on toast tonight or slice into a salad.',
    keywords: ['green', 'guacamole', 'toast', 'exotic'],
    popularity: 95,
  );
  static const carrots = Product(
    id: 'carrots',
    name: 'Baby Carrots',
    unit: '500 g · Organic',
    price: 1.89,
    art: Produce.carrot,
    tint: AppColors.tintOrange,
    categories: {Category.veggies},
    tags: {Tag.organic, Tag.local, Tag.pesticideFree},
    rating: 4.7,
    reviews: '940',
    kcal: 41,
    water: '88%',
    vitamin: 'Vit A',
    description: 'Crunchy, naturally sweet baby carrots grown in rich valley soil. Great raw, roasted or juiced.',
    keywords: ['orange', 'veggie', 'vegetable', 'root'],
    popularity: 80,
  );
  static const basil = Product(
    id: 'basil',
    name: 'Fresh Basil',
    unit: '1 bunch · Local',
    price: 1.29,
    art: Produce.basil,
    tint: AppColors.tintMint,
    categories: {Category.herbs},
    tags: {Tag.local, Tag.organic},
    rating: 4.9,
    reviews: '760',
    kcal: 23,
    water: '92%',
    vitamin: 'Vit K',
    description: 'Fragrant Genovese basil cut this morning. The secret to a vibrant pesto and the perfect margherita.',
    keywords: ['green', 'herb', 'herbs', 'pesto', 'italian'],
    popularity: 90,
  );
  static const mint = Product(
    id: 'mint',
    name: 'Fresh Mint',
    unit: '1 bunch · Local',
    price: 0.99,
    art: Produce.basil,
    tint: AppColors.tintLeaf,
    categories: {Category.herbs},
    tags: {Tag.local, Tag.pesticideFree},
    rating: 4.8,
    reviews: '510',
    kcal: 44,
    water: '86%',
    vitamin: 'Iron',
    description: 'Cool, aromatic spearmint for tea, mojitos and fresh salads. Grown without pesticides.',
    keywords: ['green', 'herb', 'herbs', 'tea', 'mojito'],
    popularity: 70,
  );
  static const apples = Product(
    id: 'apples',
    name: 'Green Apples',
    unit: '1 kg · Crisp',
    price: 2.19,
    art: Produce.apple,
    tint: AppColors.tintLime,
    categories: {Category.fruits},
    tags: {Tag.local, Tag.seasonal},
    rating: 4.7,
    reviews: '1.1k',
    kcal: 52,
    water: '86%',
    vitamin: 'Fiber',
    description: 'Tart, crisp green apples from orchards just up the road. Ideal for baking, juicing or a quick snack.',
    keywords: ['green', 'apple', 'fruit', 'baking'],
    popularity: 85,
  );
  static const oranges = Product(
    id: 'oranges',
    name: 'Navel Oranges',
    unit: '1 kg · Juicy',
    price: 1.99,
    oldPrice: 2.49,
    art: Produce.orange,
    tint: AppColors.tintOrange,
    categories: {Category.fruits},
    tags: {Tag.seasonal, Tag.sale, Tag.local},
    rating: 4.8,
    reviews: '1.4k',
    kcal: 47,
    water: '87%',
    vitamin: 'Vit C',
    description: 'Seedless navel oranges from local groves — just harvested, bursting with juice and sunshine.',
    keywords: ['orange', 'citrus', 'juice', 'fruit'],
    popularity: 88,
  );
  static const lemons = Product(
    id: 'lemons',
    name: 'Sicilian Lemons',
    unit: '500 g · Unwaxed',
    price: 2.49,
    art: Produce.lemon,
    tint: AppColors.tintLemon,
    categories: {Category.fruits},
    tags: {Tag.organic, Tag.pesticideFree},
    rating: 4.8,
    reviews: '690',
    kcal: 29,
    water: '89%',
    vitamin: 'Vit C',
    description: 'Fragrant, thin-skinned unwaxed lemons. Zest them, squeeze them, or add a slice to everything.',
    keywords: ['yellow', 'citrus', 'lemon', 'fruit'],
    popularity: 75,
  );
  static const tomatoes = Product(
    id: 'tomatoes',
    name: 'Vine Tomatoes',
    unit: '1 kg · Sweet',
    price: 2.79,
    art: Produce.tomato,
    tint: AppColors.tintBerry,
    categories: {Category.veggies, Category.fruits},
    tags: {Tag.local},
    rating: 4.7,
    reviews: '880',
    kcal: 18,
    water: '95%',
    vitamin: 'Lycopene',
    description: 'Vine-ripened tomatoes with deep summer flavour. Slice for salads or slow-roast for sauces.',
    keywords: ['red', 'tomato', 'salad', 'veggie', 'vegetable'],
    popularity: 78,
  );
  static const cherryTomatoes = Product(
    id: 'cherry-tomatoes',
    name: 'Cherry Tomatoes',
    unit: '250 g · Snacking',
    price: 1.79,
    art: Produce.tomato,
    tint: AppColors.tintOrange,
    categories: {Category.veggies},
    tags: {Tag.local, Tag.seasonal},
    rating: 4.8,
    reviews: '620',
    kcal: 18,
    water: '95%',
    vitamin: 'Vit C',
    description: 'Bite-sized and candy-sweet cherry tomatoes. Perfect for lunchboxes and quick pastas.',
    keywords: ['red', 'tomato', 'cherry', 'snack', 'veggie', 'vegetable'],
    popularity: 72,
  );
  static const broccoli = Product(
    id: 'broccoli',
    name: 'Broccoli Crown',
    unit: '1 pc · Organic',
    price: 1.59,
    art: Produce.broccoli,
    tint: AppColors.tintLeaf,
    categories: {Category.veggies},
    tags: {Tag.organic, Tag.local},
    rating: 4.6,
    reviews: '540',
    kcal: 34,
    water: '89%',
    vitamin: 'Vit K',
    description: 'Tight, deep-green organic broccoli crowns. Steam, roast or stir-fry in minutes.',
    keywords: ['green', 'veggie', 'vegetable', 'greens'],
    popularity: 68,
  );

  static const all = [strawberries, avocado, carrots, basil, apples, oranges, lemons, tomatoes, broccoli, mint, cherryTomatoes];
  static const freshPicks = [strawberries, avocado, carrots, basil];
  static const trending = [strawberries, basil, oranges];

  static Product byId(String id) => all.firstWhere((p) => p.id == id);

  static List<Product> inCategory(Category c) => all.where((p) => p.categories.contains(c)).toList();

  static const baskets = [
    Basket(
      name: 'Sunday Greens Box',
      note: '8 items · Auto-delivers Sundays',
      items: {'broccoli': 2, 'carrots': 2, 'apples': 1, 'basil': 2, 'mint': 1},
    ),
    Basket(
      name: 'Smoothie Starter',
      note: '6 items · Every other Friday',
      items: {'strawberries': 2, 'oranges': 2, 'avocado': 1, 'lemons': 1},
    ),
  ];

  static const activeOrders = [
    Order(
      id: '#FR-2481',
      items: [strawberries, avocado, basil, lemons],
      total: 10.26,
      status: OrderStatus.onTheWay,
      when: 'Arriving 4:00 – 4:30 PM',
    ),
    Order(
      id: '#FR-2479',
      items: [broccoli, carrots, tomatoes, lemons, apples, mint],
      total: 24.10,
      status: OrderStatus.packing,
      when: 'Tomorrow · 9 – 10 AM',
    ),
  ];

  static const pastOrders = [
    Order(
      id: '#FR-2470',
      items: [oranges, apples, strawberries, basil, carrots, lemons],
      total: 24.80,
      status: OrderStatus.delivered,
      when: 'Oct 18',
    ),
    Order(id: '#FR-2462', items: [tomatoes, basil, mint, broccoli], total: 16.35, status: OrderStatus.delivered, when: 'Oct 11'),
    Order(id: '#FR-2451', items: [avocado, lemons, strawberries], total: 11.40, status: OrderStatus.delivered, when: 'Oct 4'),
    Order(
      id: '#FR-2440',
      items: [carrots, broccoli, cherryTomatoes, apples, oranges],
      total: 19.05,
      status: OrderStatus.delivered,
      when: 'Sep 27',
    ),
  ];
}

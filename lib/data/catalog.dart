import '../models.dart';

import 'package:flutter/material.dart';

/// Sorted class folder names from the pacificrm SkinDisease dataset (22 classes).
const classIds = [
  'Acne',
  'Actinic_Keratosis',
  'Benign_Tumors',
  'Bullous',
  'Candidiasis',
  'Drug_Eruption',
  'Eczema',
  'Infestations_Bites',
  'Lichen',
  'Lupus',
  'Moles',
  'Psoriasis',
  'Rosacea',
  'Seborrheic_Keratoses',
  'Skin_Cancer',
  'Sun_Sunlight_Damage',
  'Tinea',
  'Unknown_Normal',
  'Vascular_Tumors',
  'Vasculitis',
  'Vitiligo',
  'Warts',
];

const displayNames = {
  'Acne': 'Acne',
  'Actinic_Keratosis': 'Actinic Keratosis',
  'Benign_Tumors': 'Benign Tumors',
  'Bullous': 'Bullous Disease',
  'Candidiasis': 'Candidiasis',
  'Drug_Eruption': 'Drug Eruption',
  'Eczema': 'Eczema',
  'Infestations_Bites': 'Infestations / Bites',
  'Lichen': 'Lichen',
  'Lupus': 'Lupus',
  'Moles': 'Moles',
  'Psoriasis': 'Psoriasis',
  'Rosacea': 'Rosacea',
  'Seborrheic_Keratoses': 'Seborrheic Keratoses',
  'Skin_Cancer': 'Skin Cancer',
  'Sun_Sunlight_Damage': 'Sun Damage',
  'Tinea': 'Tinea (Ringworm)',
  'Unknown_Normal': 'Unknown / Normal',
  'Vascular_Tumors': 'Vascular Tumors',
  'Vasculitis': 'Vasculitis',
  'Vitiligo': 'Vitiligo',
  'Warts': 'Warts',
};

final diseases = <String, DiseaseInfo>{};

const _overviews = {};
const _symptoms = {};
const _care = {};
const _seeDoctor = {};

final products = <Product>[
  Product(
    id: 'p1',
    name: 'Gentle Cleanser',
    price: 262.99,
    category: 'Cleansers',
    description:
        'A gentle, non-irritating cleanser suitable for sensitive skin.',
    diseases: ['Acne', 'Eczema', 'Rosacea'],
    imagePath: 'assets/products/gentle_cleanser.jpg',
  ),
  Product(
    id: 'p2',
    name: 'Moisturizing Lotion',
    price: 265.99,
    category: 'Moisturizers',
    description: 'Hydrating lotion with ceramides to restore skin barrier.',
    diseases: ['Eczema', 'Psoriasis', 'Vitiligo'],
    imagePath: 'assets/products/moisturizing_lotion.jpg',
  ),
  Product(
    id: 'p3',
    name: 'Acne Treatment Gel',
    price: 268.99,
    category: 'Treatments',
    description: 'Benzoyl peroxide gel for treating acne breakouts.',
    diseases: ['Acne'],
    imagePath: 'assets/products/acne_treatment_gel.jpg',
  ),
  Product(
    id: 'p4',
    name: 'Antifungal Cream',
    price: 263.99,
    category: 'Antifungals',
    description: 'Clotrimazole cream for treating fungal skin infections.',
    diseases: ['Tinea', 'Candidiasis'],
    imagePath: 'assets/products/antifungal_cream.jpg',
  ),
  Product(
    id: 'p5',
    name: 'Sunscreen SPF 50',
    price: 266.99,
    category: 'Sun care',
    description: 'Broad-spectrum sunscreen to protect against UV damage.',
    diseases: ['Sun_Sunlight_Damage', 'Actinic_Keratosis'],
    imagePath: 'assets/products/sunscreen_spf50.jpg',
  ),
  Product(
    id: 'p6',
    name: 'Soothing Aloe Gel',
    price: 261.99,
    category: 'Soothing',
    description: 'Pure aloe vera gel to soothe irritated skin.',
    diseases: ['Eczema', 'Psoriasis', 'Sun_Sunlight_Damage'],
    imagePath: 'assets/products/soothing_aloe_gel.jpg',
  ),
  Product(
    id: 'p7',
    name: 'Vitamin C Serum',
    price: 272.99,
    category: 'Serums',
    description: 'Antioxidant serum to brighten and even skin tone.',
    diseases: ['Sun_Sunlight_Damage', 'Vitiligo'],
    imagePath: 'assets/products/vitamin_c_serum.jpg',
  ),
  Product(
    id: 'p8',
    name: 'Calamine Lotion',
    price: 259.99,
    category: 'Treatments',
    description: 'Calamine lotion for relieving itching and irritation.',
    diseases: ['Chickenpox', 'Poison Ivy', 'Insect Bites'],
    imagePath: 'assets/products/calamine_lotion.jpg',
  ),
];

final categories = [
  'All',
  'Cleansers',
  'Moisturizers',
  'Treatments',
  'Antifungals',
  'Sun care',
  'Soothing',
  'Serums',
  'Camouflage',
  'Oral OTC',
  'First aid',
];

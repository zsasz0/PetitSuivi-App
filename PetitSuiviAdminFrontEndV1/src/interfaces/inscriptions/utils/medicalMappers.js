/**
 * @file inscriptions/medicalMappers.js
 * @description Transforms Flutter-format medical-form JSON into a flat key→value map.
 *
 * PURPOSE:
 * The parent-facing Flutter mobile app stores medical form answers in a nested
 * structure with four buckets:
 *   • `text`         – free-text fields  (e.g. childFullName, fatherName)
 *   • `checks`       – boolean toggles   (e.g. fatherAlive, motherAlcohol)
 *   • `singleChoice` – radio-button picks (e.g. birthPlace = "المستشفى")
 *   • `multiChoice`  – checkbox arrays    (e.g. diseases = ["الربو", "الحساسية"])
 *
 * The admin panel's `MedicalFormDocument.jsx` expects a simple flat object where
 * each key (e.g. `father_name`, `disease_asthma`) maps to a value. This mapper
 * bridges the two formats so the same rendering template works regardless of
 * which format the data was stored in.
 *
 * EXPORTED:
 * - `mapFlutterToFlat(flutterData)` – Returns a flat object if the input has a
 *   `text` property (Flutter format); otherwise returns the data unchanged.
 *
 * SECTION MAPPING:
 * - Section 1 : General info (child, parents, siblings, housing)
 * - Section 2 : Birth & disease history
 * - Section 3 : Current health status & family health
 * - Section 4 : Social / psychological condition
 * - Section 5 : Additional notes
 */

/**
 * Converts a Flutter-format nested medical-form object into a flat key→value map.
 *
 * @param {Object} flutterData – The raw form data object. If it contains a `text`
 *                                property it is treated as Flutter-nested; otherwise
 *                                it is returned unchanged (already flat).
 * @returns {Object} Flat object with snake_case keys mapped to simple values.
 */
export const mapFlutterToFlat = (flutterData) => {
    // If no `text` bucket exists, the data is already flat (or empty) → return as-is
    if (!flutterData || typeof flutterData !== 'object' || !flutterData.text) return flutterData;

    // Destructure the four Flutter buckets with safe defaults
    const { text = {}, checks = {}, singleChoice = {}, multiChoice = {} } = flutterData;
    const mapped = {};

    /** Helper: checks whether a multi-choice array contains a specific Arabic label. */
    const hasMulti = (key, value) => Array.isArray(multiChoice[key]) && multiChoice[key].includes(value);

    // Section 1
    mapped.full_name = text.childFullName;
    const dp = text.birthDatePlace || "";
    const parts = dp.split(/[-,\s]+/);
    mapped.birth_date = parts[0] ? parts[0] : "";
    mapped.birth_place = parts.slice(1).join(" ") || "";
    if (!mapped.birth_place) {
        mapped.birth_date = dp;
    }
    mapped.nationality = text.nationality;
    mapped.address = text.address;

    // Enrollment
    mapped.registered_nursery = hasMulti('previousEnrollment', 'بمحضنة');
    mapped.registered_other_kindergarten = hasMulti('previousEnrollment', 'بروضة أخرى');
    mapped.registered_other_kouttab = hasMulti('previousEnrollment', 'بكتاب آخر');
    mapped.not_registered = hasMulti('previousEnrollment', 'لا');

    mapped.previous_institution = text.institutionStudyDuration;
    mapped.parents_related = checks.parentsKinship;
    mapped.relation_details = text.kinshipDetails;

    // Father
    mapped.father_name = text.fatherName;
    mapped.father_birth_year = text.fatherBirthYear;
    mapped.father_profession = text.fatherJob;
    mapped.father_alive = checks.fatherAlive;
    mapped.father_lives_with_family = checks.fatherLivesWithFamily;
    mapped.father_divorced = checks.fatherDivorced;
    mapped.father_abroad = checks.fatherAbroad;
    mapped.father_alcohol = checks.fatherAlcohol;
    mapped.father_smoker = checks.fatherSmoking;

    // Mother
    mapped.mother_name = text.motherName;
    mapped.mother_birth_year = text.motherBirthYear;
    mapped.mother_profession = text.motherJob;
    mapped.mother_alive = checks.motherAlive;
    mapped.mother_lives_with_family = checks.motherLivesWithFamily;
    mapped.mother_divorced = checks.motherDivorced;
    mapped.mother_abroad = checks.motherAbroad;
    mapped.mother_alcohol = checks.motherAlcohol;
    mapped.mother_smoker = checks.motherSmoking;

    mapped.living_brothers = text.siblingsAliveBoys;
    mapped.living_sisters = text.siblingsAliveGirls;
    mapped.deceased_brothers = text.siblingsDeceasedBoys;
    mapped.deceased_sisters = text.siblingsDeceasedGirls;
    mapped.birth_order = text.childOrder;
    mapped.school_absence_days = text.absenceFromStudy;
    mapped.house_rooms = text.roomsCount;

    mapped.water_home = hasMulti('waterSource', 'حنفية في البيت');
    mapped.water_public = hasMulti('waterSource', 'حنفية عمومية');
    mapped.water_well = hasMulti('waterSource', 'بئر');
    mapped.water_bottles = hasMulti('waterSource', 'قوارير ماء');
    mapped.water_other = hasMulti('waterSource', 'مصدر آخر');

    mapped.health_center = text.healthSupervisingStructure;
    mapped.family_doctor = text.familyDoctor;

    // Section 2
    mapped.pregnancy_normal = singleChoice.motherPregnancyHealth === 'عادية';
    mapped.pregnancy_problems = singleChoice.motherPregnancyHealth === 'مشاكل صحية';
    mapped.pregnancy_notes = text.pregnancyHealthDetails;

    mapped.birth_home = singleChoice.birthPlace === 'بالمنزل';
    mapped.birth_hospital = singleChoice.birthPlace === 'المستشفى';
    mapped.birth_private_clinic = singleChoice.birthPlace === 'مصحة خاصة';

    mapped.birth_on_time = singleChoice.birthTiming === 'في أوانها';
    mapped.birth_premature = singleChoice.birthTiming === 'قبل أوانها';

    mapped.delivery_normal = singleChoice.deliveryType === 'عادية';
    mapped.delivery_complicated = singleChoice.deliveryType === 'غير عادية';
    mapped.delivery_notes = text.deliveryDetails;

    mapped.baby_health_normal = singleChoice.healthAtBirth === 'عادية';
    mapped.baby_health_abnormal = singleChoice.healthAtBirth === 'غير عادية';
    mapped.baby_health_notes = text.healthAtBirthDetails;

    mapped.congenital_yes = checks.congenitalMalformations === true;
    mapped.congenital_no = checks.congenitalMalformations === false;
    mapped.congenital_notes = text.malformationsDetails;

    mapped.disease_rheumatism = hasMulti('diseases', 'الروماتيزم');
    mapped.disease_joints = hasMulti('diseases', 'أمراض المفاصل');
    mapped.disease_blood = hasMulti('diseases', 'أمراض الدم');
    mapped.disease_heart = hasMulti('diseases', 'أمراض القلب');
    mapped.disease_kidney = hasMulti('diseases', 'أمراض الكلى');
    mapped.disease_lung = hasMulti('diseases', 'أمراض الرئة');
    mapped.disease_asthma = hasMulti('diseases', 'الربو');
    mapped.disease_seizure = hasMulti('diseases', 'الجذبة');
    mapped.disease_allergy = hasMulti('diseases', 'الحساسية');
    mapped.disease_glands = hasMulti('diseases', 'خلل في الغدد');
    mapped.disease_other = hasMulti('diseases', 'أمراض أخرى');
    mapped.disease_other_notes = text.diseaseOtherDetails;

    mapped.disease_measles = hasMulti('diseases2', 'الحصبة');
    mapped.disease_rubella = hasMulti('diseases2', 'الحميرة');
    mapped.disease_mumps = hasMulti('diseases2', 'النكاف');
    mapped.disease_chickenpox = hasMulti('diseases2', 'الجدري');
    mapped.disease_meningitis = hasMulti('diseases2', 'التهاب السحايا');
    mapped.disease_convulsion = hasMulti('diseases2', 'التشنج');
    mapped.disease_diabetes = hasMulti('diseases2', 'مرض السكري');
    mapped.disease_jaundice = hasMulti('diseases2', 'الصفراء');
    mapped.disease_other2 = hasMulti('diseases2', 'حالة صحية أخرى');
    mapped.disease_other2_notes = text.healthConditionOtherDetails;

    mapped.hospital_stay = checks.hospitalized;
    mapped.hospital_notes = text.hospitalizationDetails;
    mapped.surgery = checks.surgeries;
    mapped.surgery_notes = text.surgeriesDetails;
    mapped.hospital_address = text.hospitalAddress;

    // Section 3
    mapped.allergy = checks.current_allergy;
    mapped.fracture_history = checks.current_fracture_history;
    mapped.surgery_history = checks.current_surgery_history;
    mapped.motor_deficiency = checks.current_motor_deficiency;
    mapped.visual_deficiency = checks.current_visual_deficiency;
    mapped.hearing_deficiency = checks.current_hearing_deficiency;
    mapped.speech_delay = checks.current_speech_delay;
    mapped.balance_problem = checks.current_balance_trouble;
    mapped.chronic_headache = checks.current_headache;
    mapped.ear_problem = checks.current_ear_pain;
    mapped.stomach_pain = checks.current_stomach_pain;
    mapped.anemia = checks.current_anemia;
    mapped.breathing_difficulty = checks.current_breathing_difficulty;
    mapped.bladder_problem = checks.current_sphincter_trouble;
    mapped.other_health_problem = checks.current_other_health_issue;
    mapped.taking_medication = checks.current_takes_medications;
    mapped.under_treatment = checks.current_under_treatment;

    mapped.family_diabetes = checks.family_diabetes;
    mapped.family_hypertension = checks.family_hypertension;
    mapped.family_anemia = checks.family_anemia;
    mapped.family_allergy = checks.family_allergy;
    mapped.family_deafness = checks.family_deafness;
    mapped.family_genetic = checks.family_genetic;
    mapped.family_mental_delay = checks.family_mental_delay;
    mapped.family_congenital = checks.family_congenital;
    mapped.family_psychiatric = checks.family_psychiatric;
    mapped.family_obesity = checks.family_obesity;
    mapped.family_mutism = checks.family_mutism;

    // Section 4
    mapped.sibling_only = singleChoice.social_position_siblings === 'وحيد';
    mapped.sibling_oldest = singleChoice.social_position_siblings === 'الأكبر';
    mapped.sibling_middle = singleChoice.social_position_siblings === 'الأوسط';
    mapped.sibling_youngest = singleChoice.social_position_siblings === 'الأصغر';

    mapped.lives_with_father = singleChoice.social_lives_with === 'والده';
    mapped.lives_with_mother = singleChoice.social_lives_with === 'والدته';
    mapped.lives_with_both = singleChoice.social_lives_with === 'كلا الوالدين';
    mapped.lives_with_other = singleChoice.social_lives_with === 'شخص آخر';

    mapped.family_relation_normal = singleChoice.social_family_relation === 'عادية';
    mapped.family_relation_good = singleChoice.social_family_relation === 'جيدة';
    mapped.family_relation_difficult = singleChoice.social_family_relation === 'صعبة';

    mapped.behavior_normal = hasMulti('social_behavior', 'عادي');
    mapped.behavior_irritable = hasMulti('social_behavior', 'سريع الانفعال');
    mapped.behavior_aggressive = hasMulti('social_behavior', 'عدواني');
    mapped.behavior_shy = hasMulti('social_behavior', 'خجول');
    mapped.behavior_hyperactive = hasMulti('social_behavior', 'كثير الحركة');

    mapped.eating_good = singleChoice.social_eating === 'جيد';
    mapped.eating_poor = singleChoice.social_eating === 'ضعيف';
    mapped.eating_refuse = singleChoice.social_eating === 'يرفض الأكل';

    mapped.sleep_good = singleChoice.social_sleep === 'جيد';
    mapped.sleep_anxious = singleChoice.social_sleep === 'قلق';
    mapped.sleep_nightmares = singleChoice.social_sleep === 'كوابيس';

    mapped.orientation_normal = singleChoice.social_time_space === 'طبيعي';
    mapped.orientation_disorganized = singleChoice.social_time_space === 'غير منظم';

    // Section 5
    mapped.additional_notes = text.socialAdditionalInfo;

    return mapped;
};

/**
 * @file inscriptions/MedicalFormDocument.jsx
 * @description Renders a printable / viewable medical-form document (Arabic).
 *
 * PURPOSE:
 * Produces an RTL Arabic-language medical card ("بطاقة إرشادات صحية") that mirrors
 * the official Tunisian pre-school health-guidance form. The component reads
 * structured medical data (either flat or Flutter-nested JSON) and renders
 * every section: general info, birth/disease history, current health status,
 * family health, and social/psychological condition.
 *
 * PROPS:
 * @param {Object}  form        – Medical form data object (may be flat or nested Flutter format).
 * @param {string}  childName   – Fallback child name if not found in form data.
 * @param {string}  parentName  – Guardian's name shown in the footer signature area.
 * @param {boolean} isTemplate  – When true, renders an empty template with a notice banner.
 *
 * HELPERS:
 * - `getValue(...keys)` – Multi-key lookup: tries the raw form first, then the
 *                         mapped (flat) object, returning the first non-empty match.
 * - `toBool(value)`     – Normalises boolean-ish values (true, 1, '1') → true/false.
 * - `text(value)`       – Returns the value as a string, or a placeholder dotted line.
 * - `box(value)`        – Renders a checkbox glyph (✓ if truthy).
 * - `option(label, v)`  – Renders a labeled checkbox inline.
 *
 * DEPENDENCIES:
 * - `medicalMappers.js` → `mapFlutterToFlat` – Transforms Flutter-format nested
 *   JSON into a flat key→value map so the same template works with both formats.
 * - `MedicalForm.css`   – Print-friendly RTL stylesheet for the medical card layout.
 */
import React from 'react';
import './MedicalForm.css';
import { mapFlutterToFlat } from '../utils/medicalMappers';

/**
 * MedicalFormDocument Component
 * 
 * Generates a structured, printable Arabic medical report from child health data.
 * Supports both flat and nested JSON structures via internal mapping.
 * 
 * @component
 * @param {Object} props - Component props.
 * @param {Object} props.form - Raw medical form data.
 * @param {string} props.childName - Display name for the child.
 * @param {string} [props.parentName] - Guardian name for the signature area.
 * @param {boolean} [props.isTemplate=false] - If true, renders an empty form notice.
 * @returns {JSX.Element} The rendered medical document.
 */
function MedicalFormDocument({ form, childName, parentName, isTemplate = false }) {
    // Normalise input: accept either `form.form_data` wrapper or direct data
    const rawFormData = form?.form_data || form || {};
    // Convert Flutter-nested structure to flat keys for uniform access
    const nested = mapFlutterToFlat(rawFormData);

    /**
     * getValue
     * 
     * Performs a multi-layered lookup to retrieve a value from either the 
     * raw form data or the mapped nested structure.
     * 
     * @function getValue
     * @param {...string} keys - Keys to search for in order.
     * @returns {any} The first non-empty value found.
     */
    const getValue = (...keys) => {
        for (const key of keys) {
            if (key in (form || {}) && form[key] !== null && form[key] !== '') return form[key];
            if (key in nested && nested[key] !== null && nested[key] !== '') return nested[key];
        }
        return null;
    };

    // Returns the form value, or a default if no data was entered for the entire form
    const hasAnyData = form && typeof form === 'object' && Object.keys(rawFormData).length > 0 && !isTemplate;
    const getDefault = (key, defaultVal) => {
        const val = getValue(key);
        // If form has real data, return actual value (even if null); otherwise return default
        if (hasAnyData) return val;
        return val !== null ? val : defaultVal;
    };

    /**
     * toBool
     * 
     * Normalizes truthy values (booleans, numbers, strings) to a boolean.
     * 
     * @function toBool
     * @param {any} value - Value to check.
     * @returns {boolean}
     */
    const toBool = (value) => value === true || value === 1 || value === '1';
    /**
     * text
     * 
     * Formats a value for display or returns a visual placeholder if empty.
     * 
     * @function text
     * @param {any} value - Value to format.
     * @returns {string}
     */
    const text = (value) => (value === null || value === undefined || value === '' ? '.................' : String(value));
    /**
     * box
     * 
     * Renders a decorative checkbox symbol based on a truthy value.
     * 
     * @function box
     * @param {any} value - Value determining if box is checked.
     * @returns {JSX.Element}
     */
    const box = (value) => <span className={`mf-box ${toBool(value) ? 'checked' : ''}`}>{toBool(value) ? '☑' : '☐'}</span>;
    /**
     * option
     * 
     * Renders a labeled option with an associated checkbox.
     * 
     * @function option
     * @param {string} label - Label text in Arabic.
     * @param {any} value - Truthy value for the checkbox.
     * @returns {JSX.Element}
     */
    const option = (label, value) => <span className="mf-option">{label} {box(value)}</span>;

    return (
        <div className="medical-doc" dir="rtl" lang="ar">
            <div className="mf-cover">
                <div className="mf-cover-right">
                    <div>الجمهورية التونسية</div>
                    <div>********</div>
                    <div>وزارة الصحة العمومية</div>
                    <div>********</div>
                    <div>إدارة الطب المدرسي والجامعي</div>
                </div>
                <div className="mf-cover-left-box">ب/ص / ر</div>
                <div className="mf-cover-oval">
                    <div className="mf-cover-title">بطاقة إرشادات صحية</div>
                    <div className="mf-cover-title">لمستوى ما قبل الدراسة</div>
                    <div className="mf-cover-subtitle">(تعمر من قبل الولي والطبيب المباشر)</div>
                </div>
            </div>
            {isTemplate && <div className="medical-template-note">عرض قالب فارغ: لم يتم إدخال البيانات الطبية بعد.</div>}

            <div className="mf-page">
                <h3>إرشادات عامة / Informations générales</h3>
                <div className="mf-row"><label>الاسم واللقب / Nom & Prénom :</label><span className="mf-line">{text(getValue('full_name') || childName)}</span></div>
                <div className="mf-row"><label>تاريخ الولادة / Date de naissance :</label><span className="mf-line short">{text(getValue('birth_date'))}</span><label>مكان الولادة / Lieu de naissance :</label><span className="mf-line short">{text(getValue('birth_place'))}</span><label>الجنسية / Nationalité :</label><span className="mf-line short">{text(getValue('nationality'))}</span></div>
                <div className="mf-row"><label>العنوان / Adresse :</label><span className="mf-line long">{text(getValue('address'))}</span></div>
                <div className="mf-row"><label>هل كان الطفل مرسما؟ / L'enfant était-il inscrit avant ?</label>{option('بمحضنة / Crèche', getValue('registered_nursery'))}{option('بروضة أخرى / Autre jardin d\'enfants', getValue('registered_other_kindergarten'))}{option('بكتاب آخر / École coranique', getValue('registered_other_kouttab'))}{option('لا / Non', getValue('not_registered'))}</div>
                <div className="mf-row"><label>المؤسسة والمدة / Établissement & Durée :</label><span className="mf-line">{text(getValue('previous_institution'))}</span></div>
                <div className="mf-row"><label>هل هناك قرابة بين الأب والأم؟ / Lien de parenté entre les parents ?</label>{option('نعم / Oui', getValue('parents_related'))}<label>إن نعم، حددها / Si oui, précisez :</label><span className="mf-line">{text(getValue('relation_details'))}</span></div>

                <h4>الأب / Père</h4>
                <div className="mf-row"><label>اسم الأب / Nom du père :</label><span className="mf-line">{text(getValue('father_name'))}</span><label>سنة الولادة / Année de naissance :</label><span className="mf-line short">{text(getValue('father_birth_year'))}</span></div>
                <div className="mf-row"><label>المهنة / Profession :</label><span className="mf-line">{text(getValue('father_profession'))}</span></div>
                <div className="mf-row"><label>هل هو على قيد الحياة؟ / Est-il en vie ?</label>{option('نعم / Oui', getValue('father_alive'))}<label>يعيش مع أسرته / Vit avec sa famille :</label>{option('نعم / Oui', getValue('father_lives_with_family'))}</div>
                <div className="mf-row"><label>مطلق / Divorcé :</label>{option('نعم / Oui', getValue('father_divorced'))}<label>مقيم بالخارج / Réside à l\'étranger :</label>{option('نعم / Oui', getValue('father_abroad'))}</div>
                <div className="mf-row"><label>هل يتعاطى الكحول / Consomme de l\'alcool :</label>{option('نعم / Oui', getValue('father_alcohol'))}<label>السجائر / Fumeur :</label>{option('نعم / Oui', getValue('father_smoker'))}</div>

                <h4>الأم / Mère</h4>
                <div className="mf-row"><label>اسم الأم / Nom de la mère :</label><span className="mf-line">{text(getValue('mother_name'))}</span><label>سنة الولادة / Année de naissance :</label><span className="mf-line short">{text(getValue('mother_birth_year'))}</span></div>
                <div className="mf-row"><label>المهنة / Profession :</label><span className="mf-line">{text(getValue('mother_profession'))}</span></div>
                <div className="mf-row"><label>هل هي على قيد الحياة؟ / Est-elle en vie ?</label>{option('نعم / Oui', getValue('mother_alive'))}<label>تعيش مع أسرتها / Vit avec sa famille :</label>{option('نعم / Oui', getValue('mother_lives_with_family'))}</div>
                <div className="mf-row"><label>مطلقة / Divorcée :</label>{option('نعم / Oui', getValue('mother_divorced'))}<label>مقيمة بالخارج / Réside à l\'étranger :</label>{option('نعم / Oui', getValue('mother_abroad'))}</div>
                <div className="mf-row"><label>هل تتعاطى الكحول / Consomme de l\'alcool :</label>{option('نعم / Oui', getValue('mother_alcohol'))}<label>السجائر / Fumeuse :</label>{option('نعم / Oui', getValue('mother_smoker'))}</div>
                <div className="mf-row"><label>الإخوة على قيد الحياة / Frères et sœurs en vie :</label><span className="mf-line short">ذكور / Frères {text(getValue('living_brothers'))}</span><span className="mf-line short">إناث / Sœurs {text(getValue('living_sisters'))}</span></div>
                <div className="mf-row"><label>المتوفون / Frères et sœurs décédés :</label><span className="mf-line short">ذكور / Frères {text(getValue('deceased_brothers'))}</span><span className="mf-line short">إناث / Sœurs {text(getValue('deceased_sisters'))}</span></div>
                <div className="mf-row"><label>ترتيب الطفل / Ordre de l'enfant :</label><span className="mf-line short">{text(getValue('birth_order'))}</span><label>أيام الغياب / Jours d'absence :</label><span className="mf-line short">{text(getValue('school_absence_days'))}</span><label>عدد الغرف / Nbr. chambres :</label><span className="mf-line short">{text(getValue('house_rooms'))}</span></div>
                <div className="mf-row"><label>مصدر الماء / Source d'eau :</label>{option('حنفية في البيت / Robinet à la maison', getValue('water_home'))}{option('حنفية عمومية / Robinet public', getValue('water_public'))}{option('بئر / Puits', getValue('water_well'))}{option('ماء معلب / Eau en bouteille', getDefault('water_bottles', true))}{option('مصدر آخر / Autre source', getValue('water_other'))}</div>
                <div className="mf-row"><label>الهيكل الصحي / Structure de santé :</label><span className="mf-line">{text(getValue('health_center'))}</span><label>طبيب العائلة / Médecin de famille :</label><span className="mf-line">{text(getValue('family_doctor'))}</span></div>
            </div>

            <div className="mf-page">
                <h3>إرشادات عن الولادة والأمراض / Informations sur la naissance et les maladies</h3>
                <div className="mf-row"><label>الحالة الصحية للأم أثناء الحمل / Santé de la mère pendant la grossesse :</label>{option('عادية / Normale', getDefault('pregnancy_normal', true))}{option('مشاكل صحية / Problèmes de santé', getValue('pregnancy_problems'))}<label>المشاكل الصحية / Préciser les problèmes :</label><span className="mf-line">{text(getValue('pregnancy_notes'))}</span></div>
                <div className="mf-row"><label>مكان الولادة / Lieu de naissance :</label>{option('بالمنزل / À domicile', getValue('birth_home'))}{option('المستشفى / Hôpital', getDefault('birth_hospital', true))}{option('مصحة خاصة / Clinique privée', getValue('birth_private_clinic'))}</div>
                <div className="mf-row"><label>توقيت الولادة / Moment de l'accouchement :</label>{option('في أوانها / À terme', getDefault('birth_on_time', true))}{option('قبل أوانها / Prématuré', getValue('birth_premature'))}</div>
                <div className="mf-row"><label>نوع الولادة / Type d'accouchement :</label>{option('عادية / Normal', getDefault('delivery_normal', true))}{option('غير عادية / Compliqué', getValue('delivery_complicated'))}<label>تفاصيل الولادة / Préciser les détails :</label><span className="mf-line">{text(getValue('delivery_notes'))}</span></div>
                <div className="mf-row"><label>الحالة الصحية للطفل عند الولادة / État de santé à la naissance :</label>{option('عادية / Normal', getDefault('baby_health_normal', true))}{option('غير عادية / Anormal', getValue('baby_health_abnormal'))}<label>تفاصيل الحالة / Préciser les détails :</label><span className="mf-line">{text(getValue('baby_health_notes'))}</span></div>
                <div className="mf-row"><label>هل توجد تشوهات خلقية؟ / Malformations congénitales ?</label>{option('نعم / Oui', getValue('congenital_yes'))}{option('لا / Non', getDefault('congenital_no', true))}<label>التشوهات / Préciser les malformations :</label><span className="mf-line">{text(getValue('congenital_notes'))}</span></div>
                <h4>الأمراض / Historique</h4>
                <div className="mf-row">{option('الروماتيزم / Rhumatisme', getValue('disease_rheumatism'))}{option('أمراض المفاصل / Maladies articulaires', getValue('disease_joints'))}{option('أمراض الدم / Maladies du sang', getValue('disease_blood'))}{option('أمراض القلب / Maladies cardiaques', getValue('disease_heart'))}</div>
                <div className="mf-row">{option('أمراض الكلى / Maladies rénales', getValue('disease_kidney'))}{option('أمراض الرئة / Maladies pulmonaires', getValue('disease_lung'))}{option('الربو / Asthme', getValue('disease_asthma'))}{option('الجذبة / Épilepsie/Convulsions', getValue('disease_seizure'))}</div>
                <div className="mf-row">{option('الحساسية / Allergies', getValue('disease_allergy'))}{option('خلل في الغدد / Troubles glandulaires', getValue('disease_glands'))}{option('أمراض أخرى / Autres maladies', getValue('disease_other'))}<span className="mf-line">{text(getValue('disease_other_notes'))}</span></div>
                <div className="mf-row">{option('الحصبة / Rougeole', getValue('disease_measles'))}{option('الحميرة / Rubéole', getValue('disease_rubella'))}{option('النكاف / Oreillons', getValue('disease_mumps'))}{option('الجدري / Varicelle', getValue('disease_chickenpox'))}</div>
                <div className="mf-row">{option('التهاب السحايا / Méningite', getValue('disease_meningitis'))}{option('التشنج / Spasmes', getValue('disease_convulsion'))}{option('مرض السكري / Diabète', getValue('disease_diabetes'))}{option('الصفراء / Jaunisse', getValue('disease_jaundice'))}</div>
                <div className="mf-row">{option('حالة صحية أخرى / Autre condition', getValue('disease_other2'))}<span className="mf-line">{text(getValue('disease_other2_notes'))}</span></div>
                <div className="mf-row"><label>هل سبق له الإقامة بالمستشفى؟ / Déjà hospitalisé ?</label>{option('نعم / Oui', getValue('hospital_stay'))}<span className="mf-line">{text(getValue('hospital_notes'))}</span></div>
                <div className="mf-row"><label>هل خضع لعمليات جراحية؟ / Interventions chirurgicales ?</label>{option('نعم / Oui', getValue('surgery'))}<span className="mf-line">{text(getValue('surgery_notes'))}</span></div>
                <div className="mf-row"><label>عنوان المستشفى / Adresse de l'hôpital :</label><span className="mf-line">{text(getValue('hospital_address'))}</span></div>
            </div>

            <div className="mf-page">
                <h3>الحالة الصحية الحالية للطفل / État de santé actuel de l'enfant</h3>
                <table className="mf-health-table">
                    <tbody>
                        <tr><td>هل يعاني الطفل من حساسية؟ / Allergies ?</td><td>{option('نعم / Oui', getValue('allergy'))}</td></tr>
                        <tr><td>خلفيات للكسور؟ / Antécédents de fractures ?</td><td>{option('نعم / Oui', getValue('fracture_history'))}</td></tr>
                        <tr><td>خلفيات لعمليات جراحية؟ / Antécédents chirurgicaux ?</td><td>{option('نعم / Oui', getValue('surgery_history'))}</td></tr>
                        <tr><td>قصور عضلي أو حركي؟ / Déficience motrice ?</td><td>{option('نعم / Oui', getValue('motor_deficiency'))}</td></tr>
                        <tr><td>قصور بصري؟ / Déficience visuelle ?</td><td>{option('نعم / Oui', getValue('visual_deficiency'))}</td></tr>
                        <tr><td>قصور سمعي؟ / Déficience auditive ?</td><td>{option('نعم / Oui', getValue('hearing_deficiency'))}</td></tr>
                        <tr><td>تأخر في النطق؟ / Retard de parole ?</td><td>{option('نعم / Oui', getValue('speech_delay'))}</td></tr>
                        <tr><td>فقدان التوازن أو اضطراب المشي؟ / Troubles de l'équilibre ?</td><td>{option('نعم / Oui', getValue('balance_problem'))}</td></tr>
                        <tr><td>صداع مزمن؟ / Maux de tête chroniques ?</td><td>{option('نعم / Oui', getValue('chronic_headache'))}</td></tr>
                        <tr><td>آلام أو سيلان في الأذن؟ / Douleurs aux oreilles ?</td><td>{option('نعم / Oui', getValue('ear_problem'))}</td></tr>
                        <tr><td>آلام في البطن والمعدة؟ / Maux d'estomac/ventre ?</td><td>{option('نعم / Oui', getValue('stomach_pain'))}</td></tr>
                        <tr><td>فقر الدم؟ / Anémie ?</td><td>{option('نعم / Oui', getValue('anemia'))}</td></tr>
                        <tr><td>صعوبات في التنفس؟ / Difficultés respiratoires ?</td><td>{option('نعم / Oui', getValue('breathing_difficulty'))}</td></tr>
                        <tr><td>اضطرابات في المثانة؟ / Troubles sphinctériens ?</td><td>{option('نعم / Oui', getValue('bladder_problem'))}</td></tr>
                        <tr><td>مشاكل صحية أخرى؟ / Autres problèmes de santé ?</td><td>{option('نعم / Oui', getValue('other_health_problem'))}</td></tr>
                        <tr><td>هل يتناول حالياً أدوية؟ / Prend des médicaments ?</td><td>{option('نعم / Oui', getValue('taking_medication'))}</td></tr>
                        <tr><td>هل يتلقى حالياً علاجاً أو إشرافاً طبياً؟ / Sous traitement ou suivi médical ?</td><td>{option('نعم / Oui', getValue('under_treatment'))}</td></tr>
                    </tbody>
                </table>
                <h4>صحة العائلة / Santé familiale</h4>
                <div className="mf-row">{option('السكري / Diabète', getValue('family_diabetes'))}{option('ضغط الدم / Hypertension', getValue('family_hypertension'))}{option('فقر الدم / Anémie', getValue('family_anemia'))}{option('حساسية / Allergies', getValue('family_allergy'))}</div>
                <div className="mf-row">{option('الصمم / Surdité', getValue('family_deafness'))}{option('مرض وراثي / Maladie génétique', getValue('family_genetic'))}{option('تأخر ذهني / Retard mental', getValue('family_mental_delay'))}{option('مرض خلقي / Maladie congénitale', getValue('family_congenital'))}</div>
                <div className="mf-row">{option('مرض نفسي / Maladie psychiatrique', getValue('family_psychiatric'))}{option('السمنة / Obésité', getValue('family_obesity'))}{option('البكم / Mutisme', getValue('family_mutism'))}</div>
            </div>

            <div className="mf-page">
                <h3>الوضع الاجتماعي والنفسي للطفل / Situation sociale et psychologique</h3>
                <div className="mf-row"><label>وضعية الطفل بين الإخوة / Position parmi les frères et sœurs :</label>{option('وحيد / Unique', getValue('sibling_only'))}{option('الأكبر / Aîné', getValue('sibling_oldest'))}{option('الأوسط / Cadet', getValue('sibling_middle'))}{option('الأصغر / Benjamin', getValue('sibling_youngest'))}</div>
                <div className="mf-row"><label>يقيم الطفل عادة مع / L'enfant vit avec :</label>{option('والده / Son père', getValue('lives_with_father'))}{option('والدته / Sa mère', getValue('lives_with_mother'))}{option('كلا الوالدين / Ses deux parents', getDefault('lives_with_both', true))}{option('شخص آخر / Autre personne', getValue('lives_with_other'))}</div>
                <div className="mf-row"><label>علاقة الطفل مع العائلة / Relation avec la famille :</label>{option('عادية / Normale', getDefault('family_relation_normal', true))}{option('جيدة / Bonne', getValue('family_relation_good'))}{option('صعبة / Difficile', getValue('family_relation_difficult'))}</div>
                <div className="mf-row"><label>السلوك العام للطفل / Comportement général :</label>{option('عادي / Normal', getDefault('behavior_normal', true))}{option('سريع الانفعال / Irritable', getValue('behavior_irritable'))}{option('عدواني / Agressif', getValue('behavior_aggressive'))}{option('خجول / Timide', getValue('behavior_shy'))}{option('كثير الحركة / Hyperactif', getValue('behavior_hyperactive'))}</div>
                <div className="mf-row"><label>طبيعة تناول الأكل / Alimentation :</label>{option('جيد / Bonne', getDefault('eating_good', true))}{option('ضعيف / Faible', getValue('eating_poor'))}{option('يرفض الأكل / Refuse de manger', getValue('eating_refuse'))}</div>
                <div className="mf-row"><label>طبيعة النوم / Sommeil :</label>{option('جيد / Bon', getDefault('sleep_good', true))}{option('قلق / Agité', getValue('sleep_anxious'))}{option('كوابيس / Cauchemars', getValue('sleep_nightmares'))}</div>
                <div className="mf-row"><label>النظام الزمني والمكاني / Repères spatio-temporels :</label>{option('طبيعي / Normaux', getDefault('orientation_normal', true))}{option('غير منظم / Désorganisés', getValue('orientation_disorganized'))}</div>
                <div className="mf-notes">
                    <h4>ملاحظات إضافية / Remarques supplémentaires</h4>
                    <div className="mf-lines">{text(getValue('additional_notes'))}</div>
                </div>
                <div className="mf-footer">
                    <span>الولي: {text(parentName)}</span>
                    <span>تاريخ التحصيل: {text(form?.submitted_at || form?.updated_at)}</span>
                </div>
                <div className="mf-sign-strip">
                    <div className="mf-sign-col">
                        <div className="mf-sign-date"><span>التاريخ</span><div className="mf-sign-dots"></div></div>
                        <div className="mf-sign-text">اسم الطبيب المدرسي ولقبه</div>
                        <div className="mf-sign-text">وختمه وإمضاؤه</div>
                        <div className="mf-sign-line"></div>
                    </div>
                    <div className="mf-sign-col">
                        <div className="mf-sign-date"><span>التاريخ</span><div className="mf-sign-dots"></div></div>
                        <div className="mf-sign-text">إمضاء الولي</div>
                        <div className="mf-sign-line"></div>
                        <div className="mf-sign-checks">
                            <span className="mf-option">الأب {box(false)}</span>
                            <span className="mf-option">الأم {box(false)}</span>
                        </div>
                    </div>
                    <div className="mf-sign-col">
                        <div className="mf-sign-date"><span>التاريخ</span><div className="mf-sign-dots"></div></div>
                        <div className="mf-sign-text">اسم الطبيب المباشر ولقبه</div>
                        <div className="mf-sign-text">وختمه وإمضاؤه</div>
                        <div className="mf-sign-line"></div>
                    </div>
                </div>
            </div>
        </div>
    );
}

export default MedicalFormDocument;

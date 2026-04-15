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
                <h3>إرشادات عامة :</h3>
                <div className="mf-row"><label>اسم الطفل ولقبه :</label><span className="mf-line">{text(getValue('full_name') || childName)}</span></div>
                <div className="mf-row"><label>تاريخ ومكان الولادة :</label><span className="mf-line">{text(getValue('birth_date'))} - {text(getValue('birth_place'))}</span><label>الجنسية :</label><span className="mf-line">{text(getValue('nationality'))}</span></div>
                <div className="mf-row"><label>العنوان :</label><span className="mf-line long">{text(getValue('address'))}</span></div>
                <div className="mf-row"><label>هل كان الطفل مرسما ؟</label>{option('بمَحضنة', getValue('registered_nursery'))}{option('بروضة أخرى', getValue('registered_other_kindergarten'))}{option('بكتاب آخر', getValue('registered_other_kouttab'))}{option('لا', getValue('not_registered'))}</div>
                <div className="mf-row"><label>اسم المؤسسة، مدة الدراسة :</label><span className="mf-line">{text(getValue('previous_institution'))}</span></div>
                <div className="mf-row"><label>هل هناك قرابة بين الأب والأم ؟</label>{option('نعم', getValue('parents_related'))}<label>حددها :</label><span className="mf-line">{text(getValue('relation_details'))}</span></div>

                <h4>الأب</h4>
                <div className="mf-row"><label>اسم الأب :</label><span className="mf-line">{text(getValue('father_name'))}</span><label>سنة الولادة :</label><span className="mf-line short">{text(getValue('father_birth_year'))}</span></div>
                <div className="mf-row"><label>المهنة :</label><span className="mf-line">{text(getValue('father_profession'))}</span></div>
                <div className="mf-row"><label>هل هو على قيد الحياة ؟</label>{option('نعم', getValue('father_alive'))}<label>يعيش مع أسرته :</label>{option('نعم', getValue('father_lives_with_family'))}</div>
                <div className="mf-row"><label>مطلق :</label>{option('نعم', getValue('father_divorced'))}<label>مقيم بالخارج :</label>{option('نعم', getValue('father_abroad'))}</div>
                <div className="mf-row"><label>هل يتعاطى الكحول :</label>{option('نعم', getValue('father_alcohol'))}<label>السجائر :</label>{option('نعم', getValue('father_smoker'))}</div>

                <h4>الأم</h4>
                <div className="mf-row"><label>اسم الأم :</label><span className="mf-line">{text(getValue('mother_name'))}</span><label>سنة الولادة :</label><span className="mf-line short">{text(getValue('mother_birth_year'))}</span></div>
                <div className="mf-row"><label>المهنة :</label><span className="mf-line">{text(getValue('mother_profession'))}</span></div>
                <div className="mf-row"><label>هل هي على قيد الحياة ؟</label>{option('نعم', getValue('mother_alive'))}<label>تعيش مع أسرتها :</label>{option('نعم', getValue('mother_lives_with_family'))}</div>
                <div className="mf-row"><label>مطلقة :</label>{option('نعم', getValue('mother_divorced'))}<label>مقيمة بالخارج :</label>{option('نعم', getValue('mother_abroad'))}</div>
                <div className="mf-row"><label>هل تتعاطى الكحول :</label>{option('نعم', getValue('mother_alcohol'))}<label>السجائر :</label>{option('نعم', getValue('mother_smoker'))}</div>
                <div className="mf-row"><label>الإخوة على قيد الحياة :</label><span className="mf-line short">ذكور {text(getValue('living_brothers'))}</span><span className="mf-line short">إناث {text(getValue('living_sisters'))}</span></div>
                <div className="mf-row"><label>المتوفون :</label><span className="mf-line short">ذكور {text(getValue('deceased_brothers'))}</span><span className="mf-line short">إناث {text(getValue('deceased_sisters'))}</span></div>
                <div className="mf-row"><label>ترتيب الولد :</label><span className="mf-line short">{text(getValue('birth_order'))}</span><label>أيام الغياب :</label><span className="mf-line short">{text(getValue('school_absence_days'))}</span><label>عدد الغرف :</label><span className="mf-line short">{text(getValue('house_rooms'))}</span></div>
                <div className="mf-row"><label>مصدر الماء :</label>{option('حنفية في البيت', getValue('water_home'))}{option('حنفية عمومية', getValue('water_public'))}{option('بئر', getValue('water_well'))}{option('قوارير ماء', getDefault('water_bottles', true))}{option('مصدر آخر', getValue('water_other'))}</div>
                <div className="mf-row"><label>الهيكل الصحي :</label><span className="mf-line">{text(getValue('health_center'))}</span><label>طبيب العائلة :</label><span className="mf-line">{text(getValue('family_doctor'))}</span></div>
            </div>

            <div className="mf-page">
                <h3>إرشادات عن الولادة والأمراض :</h3>
                <div className="mf-row"><label>الحالة الصحية للأم أثناء الحمل :</label>{option('عادية', getDefault('pregnancy_normal', true))}{option('مشاكل صحية', getValue('pregnancy_problems'))}<label>اذكرها :</label><span className="mf-line">{text(getValue('pregnancy_notes'))}</span></div>
                <div className="mf-row"><label>مكان الولادة :</label>{option('بالمنزل', getValue('birth_home'))}{option('المستشفى', getDefault('birth_hospital', true))}{option('مصحة خاصة', getValue('birth_private_clinic'))}</div>
                <div className="mf-row"><label>تمت الولادة :</label>{option('في أوانها', getDefault('birth_on_time', true))}{option('قبل أوانها', getValue('birth_premature'))}</div>
                <div className="mf-row"><label>الولادة :</label>{option('عادية', getDefault('delivery_normal', true))}{option('غير عادية', getValue('delivery_complicated'))}<label>اذكرها :</label><span className="mf-line">{text(getValue('delivery_notes'))}</span></div>
                <div className="mf-row"><label>الحالة الصحية للطفل عند الولادة :</label>{option('عادية', getDefault('baby_health_normal', true))}{option('غير عادية', getValue('baby_health_abnormal'))}<label>اذكرها :</label><span className="mf-line">{text(getValue('baby_health_notes'))}</span></div>
                <div className="mf-row"><label>تشوهات خلقية :</label>{option('نعم', getValue('congenital_yes'))}{option('لا', getDefault('congenital_no', true))}<label>اذكرها :</label><span className="mf-line">{text(getValue('congenital_notes'))}</span></div>
                <h4>الأمراض التي تعرض لها الطفل</h4>
                <div className="mf-row">{option('الروماتيزم', getValue('disease_rheumatism'))}{option('أمراض المفاصل', getValue('disease_joints'))}{option('أمراض الدم', getValue('disease_blood'))}{option('أمراض القلب', getValue('disease_heart'))}</div>
                <div className="mf-row">{option('أمراض الكلى', getValue('disease_kidney'))}{option('أمراض الرئة', getValue('disease_lung'))}{option('الربو', getValue('disease_asthma'))}{option('الجذبة', getValue('disease_seizure'))}</div>
                <div className="mf-row">{option('الحساسية', getValue('disease_allergy'))}{option('خلل في الغدد', getValue('disease_glands'))}{option('أمراض أخرى', getValue('disease_other'))}<span className="mf-line">{text(getValue('disease_other_notes'))}</span></div>
                <div className="mf-row">{option('الحصبة', getValue('disease_measles'))}{option('الحميرة', getValue('disease_rubella'))}{option('النكاف', getValue('disease_mumps'))}{option('الجدري', getValue('disease_chickenpox'))}</div>
                <div className="mf-row">{option('التهاب السحايا', getValue('disease_meningitis'))}{option('التشنج', getValue('disease_convulsion'))}{option('مرض السكري', getValue('disease_diabetes'))}{option('الصفراء', getValue('disease_jaundice'))}</div>
                <div className="mf-row">{option('حالة صحية أخرى', getValue('disease_other2'))}<span className="mf-line">{text(getValue('disease_other2_notes'))}</span></div>
                <div className="mf-row"><label>الإقامة بالمستشفى :</label>{option('نعم', getValue('hospital_stay'))}<span className="mf-line">{text(getValue('hospital_notes'))}</span></div>
                <div className="mf-row"><label>عمليات جراحية :</label>{option('نعم', getValue('surgery'))}<span className="mf-line">{text(getValue('surgery_notes'))}</span></div>
                <div className="mf-row"><label>عنوان المستشفى/المصحة :</label><span className="mf-line">{text(getValue('hospital_address'))}</span></div>
            </div>

            <div className="mf-page">
                <h3>الحالة الصحية الحالية للطفل :</h3>
                <table className="mf-health-table">
                    <tbody>
                        <tr><td>هل يعاني الطفل من حساسية</td><td>{option('نعم', getValue('allergy'))}</td></tr>
                        <tr><td>خلفيات للكسور</td><td>{option('نعم', getValue('fracture_history'))}</td></tr>
                        <tr><td>خلفيات عملية جراحية</td><td>{option('نعم', getValue('surgery_history'))}</td></tr>
                        <tr><td>قصور عضلي أو حركي</td><td>{option('نعم', getValue('motor_deficiency'))}</td></tr>
                        <tr><td>قصور بصري</td><td>{option('نعم', getValue('visual_deficiency'))}</td></tr>
                        <tr><td>قصور سمعي</td><td>{option('نعم', getValue('hearing_deficiency'))}</td></tr>
                        <tr><td>تأخر في النطق</td><td>{option('نعم', getValue('speech_delay'))}</td></tr>
                        <tr><td>فقدان التوازن/اضطراب المشي</td><td>{option('نعم', getValue('balance_problem'))}</td></tr>
                        <tr><td>صداع مزمن</td><td>{option('نعم', getValue('chronic_headache'))}</td></tr>
                        <tr><td>آلام أو سيلان في الأذن</td><td>{option('نعم', getValue('ear_problem'))}</td></tr>
                        <tr><td>آلام في البطن/المعدة</td><td>{option('نعم', getValue('stomach_pain'))}</td></tr>
                        <tr><td>فقر الدم</td><td>{option('نعم', getValue('anemia'))}</td></tr>
                        <tr><td>صعوبات في التنفس</td><td>{option('نعم', getValue('breathing_difficulty'))}</td></tr>
                        <tr><td>اضطرابات المثانة</td><td>{option('نعم', getValue('bladder_problem'))}</td></tr>
                        <tr><td>مشاكل صحية أخرى</td><td>{option('نعم', getValue('other_health_problem'))}</td></tr>
                        <tr><td>يتناول حاليا أدوية</td><td>{option('نعم', getValue('taking_medication'))}</td></tr>
                        <tr><td>يتلقى حاليا علاجا/إشرافا</td><td>{option('نعم', getValue('under_treatment'))}</td></tr>
                    </tbody>
                </table>
                <h4>الحالة الصحية للعائلة والأقارب :</h4>
                <div className="mf-row">{option('السكري', getValue('family_diabetes'))}{option('ضغط الدم', getValue('family_hypertension'))}{option('فقر الدم', getValue('family_anemia'))}{option('حساسية', getValue('family_allergy'))}</div>
                <div className="mf-row">{option('الصمم', getValue('family_deafness'))}{option('مرض وراثي', getValue('family_genetic'))}{option('تأخر ذهني', getValue('family_mental_delay'))}{option('مرض خلقي', getValue('family_congenital'))}</div>
                <div className="mf-row">{option('مرض نفسي', getValue('family_psychiatric'))}{option('السمنة', getValue('family_obesity'))}{option('البكم', getValue('family_mutism'))}</div>
            </div>

            <div className="mf-page">
                <h3>الوضع الاجتماعي والنفسي للطفل</h3>
                <div className="mf-row"><label>وضعية الطفل بين الإخوة:</label>{option('وحيد', getValue('sibling_only'))}{option('الأكبر', getValue('sibling_oldest'))}{option('الأوسط', getValue('sibling_middle'))}{option('الأصغر', getValue('sibling_youngest'))}</div>
                <div className="mf-row"><label>يقيم الطفل عادة مع:</label>{option('والده', getValue('lives_with_father'))}{option('والدته', getValue('lives_with_mother'))}{option('كلا الوالدين', getDefault('lives_with_both', true))}{option('شخص آخر', getValue('lives_with_other'))}</div>
                <div className="mf-row"><label>علاقة الطفل مع العائلة:</label>{option('عادية', getDefault('family_relation_normal', true))}{option('جيدة', getValue('family_relation_good'))}{option('صعبة', getValue('family_relation_difficult'))}</div>
                <div className="mf-row"><label>السلوك العام للطفل:</label>{option('عادي', getDefault('behavior_normal', true))}{option('سريع الانفعال', getValue('behavior_irritable'))}{option('عدواني', getValue('behavior_aggressive'))}{option('خجول', getValue('behavior_shy'))}{option('كثير الحركة', getValue('behavior_hyperactive'))}</div>
                <div className="mf-row"><label>تناول الأكل:</label>{option('جيد', getDefault('eating_good', true))}{option('ضعيف', getValue('eating_poor'))}{option('يرفض الأكل', getValue('eating_refuse'))}</div>
                <div className="mf-row"><label>النوم:</label>{option('جيد', getDefault('sleep_good', true))}{option('قلق', getValue('sleep_anxious'))}{option('كوابيس', getValue('sleep_nightmares'))}</div>
                <div className="mf-row"><label>النظام الزمني المكاني:</label>{option('طبيعي', getDefault('orientation_normal', true))}{option('غير منظم', getValue('orientation_disorganized'))}</div>
                <div className="mf-notes">
                    <h4>معلومات إضافية تفيد الطبيب المدرسي</h4>
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

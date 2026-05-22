const mockData = {
  form_data: {
    "text": {}, "checks": {}, "singleChoice": { "social_position_siblings": "وحيد / Unique" }
  }
};
// simulate MedicalFormDocument
import { mapFlutterToFlat } from './PetitSuiviAdminFrontEndV1/src/interfaces/inscriptions/utils/medicalMappers.js';

const rawFormData = mockData.form_data || mockData || {};
const nested = mapFlutterToFlat(rawFormData);
const getValue = (...keys) => {
    for (const key of keys) {
        if (key in (mockData || {}) && mockData[key] !== null && mockData[key] !== '') return mockData[key];
        if (key in nested && nested[key] !== null && nested[key] !== '') return nested[key];
    }
    return null;
};

console.log("getValue('sibling_only'):", getValue('sibling_only'));

CREATE TABLE person (
			person_id integer NOT NULL PRIMARY KEY,
			gender_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			year_of_birth integer NOT NULL,
			month_of_birth integer NULL,
			day_of_birth integer NULL,
			birth_datetime datetime NULL,
			race_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			ethnicity_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			location_id integer NULL REFERENCES LOCATION (LOCATION_ID),
			provider_id integer NULL REFERENCES PROVIDER (PROVIDER_ID),
			care_site_id integer NULL REFERENCES CARE_SITE (CARE_SITE_ID),
			person_source_value TEXT NULL,
			gender_source_value TEXT NULL,
			gender_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			race_source_value TEXT NULL,
			race_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			ethnicity_source_value TEXT NULL,
			ethnicity_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID));
CREATE TABLE observation_period (
			observation_period_id integer NOT NULL PRIMARY KEY,
			person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
			observation_period_start_date date NOT NULL,
			observation_period_end_date date NOT NULL,
			period_type_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID));
CREATE TABLE visit_occurrence (
			visit_occurrence_id integer NOT NULL PRIMARY KEY,
			person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
			visit_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			visit_start_date date NOT NULL,
			visit_start_datetime datetime NULL,
			visit_end_date date NOT NULL,
			visit_end_datetime datetime NULL,
			visit_type_concept_id Integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			provider_id integer NULL REFERENCES PROVIDER (PROVIDER_ID),
			care_site_id integer NULL REFERENCES CARE_SITE (CARE_SITE_ID),
			visit_source_value TEXT NULL,
			visit_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			admitted_from_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			admitted_from_source_value TEXT NULL,
			discharged_to_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			discharged_to_source_value TEXT NULL,
			preceding_visit_occurrence_id integer NULL REFERENCES VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID));
CREATE TABLE visit_detail (
			visit_detail_id integer NOT NULL PRIMARY KEY,
			person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
			visit_detail_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			visit_detail_start_date date NOT NULL,
			visit_detail_start_datetime datetime NULL,
			visit_detail_end_date date NOT NULL,
			visit_detail_end_datetime datetime NULL,
			visit_detail_type_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			provider_id integer NULL REFERENCES PROVIDER (PROVIDER_ID),
			care_site_id integer NULL REFERENCES CARE_SITE (CARE_SITE_ID),
			visit_detail_source_value TEXT NULL,
			visit_detail_source_concept_id Integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			admitted_from_concept_id Integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			admitted_from_source_value TEXT NULL,
			discharged_to_source_value TEXT NULL,
			discharged_to_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			preceding_visit_detail_id integer NULL REFERENCES VISIT_DETAIL (VISIT_DETAIL_ID),
			parent_visit_detail_id integer NULL REFERENCES VISIT_DETAIL (VISIT_DETAIL_ID),
			visit_occurrence_id integer NOT NULL REFERENCES VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID));
CREATE TABLE condition_occurrence (
			condition_occurrence_id integer NOT NULL PRIMARY KEY,
			person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
			condition_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			condition_start_date date NOT NULL,
			condition_start_datetime datetime NULL,
			condition_end_date date NULL,
			condition_end_datetime datetime NULL,
			condition_type_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			condition_status_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			stop_reason TEXT NULL,
			provider_id integer NULL REFERENCES PROVIDER (PROVIDER_ID),
			visit_occurrence_id integer NULL REFERENCES VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID),
			visit_detail_id integer NULL REFERENCES VISIT_DETAIL (VISIT_DETAIL_ID),
			condition_source_value TEXT NULL,
			condition_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			condition_status_source_value TEXT NULL );
CREATE TABLE drug_exposure (
			drug_exposure_id integer NOT NULL PRIMARY KEY,
			person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
			drug_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			drug_exposure_start_date date NOT NULL,
			drug_exposure_start_datetime datetime NULL,
			drug_exposure_end_date date NOT NULL,
			drug_exposure_end_datetime datetime NULL,
			verbatim_end_date date NULL,
			drug_type_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			stop_reason TEXT NULL,
			refills integer NULL,
			quantity REAL NULL,
			days_supply integer NULL,
			sig TEXT NULL,
			route_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			lot_number TEXT NULL,
			provider_id integer NULL REFERENCES PROVIDER (PROVIDER_ID),
			visit_occurrence_id integer NULL REFERENCES VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID),
			visit_detail_id integer NULL REFERENCES VISIT_DETAIL (VISIT_DETAIL_ID),
			drug_source_value TEXT NULL,
			drug_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			route_source_value TEXT NULL,
			dose_unit_source_value TEXT NULL );
CREATE TABLE procedure_occurrence (
			procedure_occurrence_id integer NOT NULL PRIMARY KEY,
			person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
			procedure_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			procedure_date date NOT NULL,
			procedure_datetime datetime NULL,
			procedure_end_date date NULL,
			procedure_end_datetime datetime NULL,
			procedure_type_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			modifier_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			quantity integer NULL,
			provider_id integer NULL REFERENCES PROVIDER (PROVIDER_ID),
			visit_occurrence_id integer NULL REFERENCES VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID),
			visit_detail_id integer NULL REFERENCES VISIT_DETAIL (VISIT_DETAIL_ID),
			procedure_source_value TEXT NULL,
			procedure_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			modifier_source_value TEXT NULL );
CREATE TABLE device_exposure (
			device_exposure_id integer NOT NULL PRIMARY KEY,
			person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
			device_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			device_exposure_start_date date NOT NULL,
			device_exposure_start_datetime datetime NULL,
			device_exposure_end_date date NULL,
			device_exposure_end_datetime datetime NULL,
			device_type_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			unique_device_id TEXT NULL,
			production_id TEXT NULL,
			quantity integer NULL,
			provider_id integer NULL REFERENCES PROVIDER (PROVIDER_ID),
			visit_occurrence_id integer NULL REFERENCES VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID),
			visit_detail_id integer NULL REFERENCES VISIT_DETAIL (VISIT_DETAIL_ID),
			device_source_value TEXT NULL,
			device_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			unit_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			unit_source_value TEXT NULL,
			unit_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID));
CREATE TABLE measurement (
			measurement_id integer NOT NULL PRIMARY KEY,
			person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
			measurement_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			measurement_date date NOT NULL,
			measurement_datetime datetime NULL,
			measurement_time TEXT NULL,
			measurement_type_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			operator_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			value_as_number REAL NULL,
			value_as_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			unit_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			range_low REAL NULL,
			range_high REAL NULL,
			provider_id integer NULL REFERENCES PROVIDER (PROVIDER_ID),
			visit_occurrence_id integer NULL REFERENCES VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID),
			visit_detail_id integer NULL REFERENCES VISIT_DETAIL (VISIT_DETAIL_ID),
			measurement_source_value TEXT NULL,
			measurement_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			unit_source_value TEXT NULL,
			unit_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			value_source_value TEXT NULL,
			measurement_event_id integer NULL,
			meas_event_field_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID));
CREATE TABLE observation (
			observation_id integer NOT NULL PRIMARY KEY,
			person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
			observation_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			observation_date date NOT NULL,
			observation_datetime datetime NULL,
			observation_type_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			value_as_number REAL NULL,
			value_as_string TEXT NULL,
			value_as_concept_id Integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			qualifier_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			unit_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			provider_id integer NULL REFERENCES PROVIDER (PROVIDER_ID),
			visit_occurrence_id integer NULL REFERENCES VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID),
			visit_detail_id integer NULL REFERENCES VISIT_DETAIL (VISIT_DETAIL_ID),
			observation_source_value TEXT NULL,
			observation_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			unit_source_value TEXT NULL,
			qualifier_source_value TEXT NULL,
			value_source_value TEXT NULL,
			observation_event_id integer NULL,
			obs_event_field_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID));
CREATE TABLE death (
			person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
			death_date date NOT NULL,
			death_datetime datetime NULL,
			death_type_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			cause_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			cause_source_value TEXT NULL,
			cause_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID));
CREATE TABLE note (
			note_id integer NOT NULL PRIMARY KEY,
			person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
			note_date date NOT NULL,
			note_datetime datetime NULL,
			note_type_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			note_class_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			note_title TEXT NULL,
			note_text TEXT NOT NULL,
			encoding_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			language_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			provider_id integer NULL REFERENCES PROVIDER (PROVIDER_ID),
			visit_occurrence_id integer NULL REFERENCES VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID),
			visit_detail_id integer NULL REFERENCES VISIT_DETAIL (VISIT_DETAIL_ID),
			note_source_value TEXT NULL,
			note_event_id integer NULL,
			note_event_field_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID));
CREATE TABLE note_nlp (
			note_nlp_id integer NOT NULL PRIMARY KEY,
			note_id integer NOT NULL,
			section_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			snippet TEXT NULL,
			"offset" TEXT NULL,
			lexical_variant TEXT NOT NULL,
			note_nlp_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			note_nlp_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			nlp_system TEXT NULL,
			nlp_date date NOT NULL,
			nlp_datetime datetime NULL,
			term_exists TEXT NULL,
			term_temporal TEXT NULL,
			term_modifiers TEXT NULL );
CREATE TABLE specimen (
			specimen_id integer NOT NULL PRIMARY KEY,
			person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
			specimen_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			specimen_type_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			specimen_date date NOT NULL,
			specimen_datetime datetime NULL,
			quantity REAL NULL,
			unit_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			anatomic_site_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			disease_status_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			specimen_source_id TEXT NULL,
			specimen_source_value TEXT NULL,
			unit_source_value TEXT NULL,
			anatomic_site_source_value TEXT NULL,
			disease_status_source_value TEXT NULL );
CREATE TABLE fact_relationship (
			domain_concept_id_1 integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			fact_id_1 integer NOT NULL,
			domain_concept_id_2 integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			fact_id_2 integer NOT NULL,
			relationship_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID));
CREATE TABLE location (
			location_id integer NOT NULL PRIMARY KEY,
			address_1 TEXT NULL,
			address_2 TEXT NULL,
			city TEXT NULL,
			state TEXT NULL,
			zip TEXT NULL,
			county TEXT NULL,
			location_source_value TEXT NULL,
			country_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			country_source_value TEXT NULL,
			latitude REAL NULL,
			longitude REAL NULL );
CREATE TABLE care_site (
			care_site_id integer NOT NULL PRIMARY KEY,
			care_site_name TEXT NULL,
			place_of_service_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			location_id integer NULL REFERENCES LOCATION (LOCATION_ID),
			care_site_source_value TEXT NULL,
			place_of_service_source_value TEXT NULL );
CREATE TABLE provider (
			provider_id integer NOT NULL PRIMARY KEY,
			provider_name TEXT NULL,
			npi TEXT NULL,
			dea TEXT NULL,
			specialty_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			care_site_id integer NULL REFERENCES CARE_SITE (CARE_SITE_ID),
			year_of_birth integer NULL,
			gender_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			provider_source_value TEXT NULL,
			specialty_source_value TEXT NULL,
			specialty_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			gender_source_value TEXT NULL,
			gender_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID));
CREATE TABLE payer_plan_period (
			payer_plan_period_id integer NOT NULL PRIMARY KEY,
			person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
			payer_plan_period_start_date date NOT NULL,
			payer_plan_period_end_date date NOT NULL,
			payer_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			payer_source_value TEXT NULL,
			payer_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			plan_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			plan_source_value TEXT NULL,
			plan_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			sponsor_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			sponsor_source_value TEXT NULL,
			sponsor_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			family_source_value TEXT NULL,
			stop_reason_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			stop_reason_source_value TEXT NULL,
			stop_reason_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID));
CREATE TABLE cost (
			cost_id integer NOT NULL PRIMARY KEY,
			cost_event_id integer NOT NULL,
			cost_domain_id TEXT NOT NULL REFERENCES DOMAIN (DOMAIN_ID),
			cost_type_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			currency_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			total_charge REAL NULL,
			total_cost REAL NULL,
			total_paid REAL NULL,
			paid_by_payer REAL NULL,
			paid_by_patient REAL NULL,
			paid_patient_copay REAL NULL,
			paid_patient_coinsurance REAL NULL,
			paid_patient_deductible REAL NULL,
			paid_by_primary REAL NULL,
			paid_ingredient_cost REAL NULL,
			paid_dispensing_fee REAL NULL,
			payer_plan_period_id integer NULL,
			amount_allowed REAL NULL,
			revenue_code_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			revenue_code_source_value TEXT NULL,
			drg_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			drg_source_value TEXT NULL );
CREATE TABLE drug_era (
			drug_era_id integer NOT NULL PRIMARY KEY,
			person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
			drug_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			drug_era_start_date date NOT NULL,
			drug_era_end_date date NOT NULL,
			drug_exposure_count integer NULL,
			gap_days integer NULL );
CREATE TABLE dose_era (
			dose_era_id integer NOT NULL PRIMARY KEY,
			person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
			drug_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			unit_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			dose_value REAL NOT NULL,
			dose_era_start_date date NOT NULL,
			dose_era_end_date date NOT NULL );
CREATE TABLE condition_era (
			condition_era_id integer NOT NULL PRIMARY KEY,
			person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
			condition_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			condition_era_start_date date NOT NULL,
			condition_era_end_date date NOT NULL,
			condition_occurrence_count integer NULL );
CREATE TABLE episode (
			episode_id integer NOT NULL PRIMARY KEY,
			person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
			episode_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			episode_start_date date NOT NULL,
			episode_start_datetime datetime NULL,
			episode_end_date date NULL,
			episode_end_datetime datetime NULL,
			episode_parent_id integer NULL,
			episode_number integer NULL,
			episode_object_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			episode_type_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			episode_source_value TEXT NULL,
			episode_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID));
CREATE TABLE episode_event (
			episode_id integer NOT NULL REFERENCES EPISODE (EPISODE_ID),
			event_id integer NOT NULL,
			episode_event_field_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID));
CREATE TABLE metadata (
			metadata_id integer NOT NULL PRIMARY KEY,
			metadata_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			metadata_type_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			name TEXT NOT NULL,
			value_as_string TEXT NULL,
			value_as_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			value_as_number REAL NULL,
			metadata_date date NULL,
			metadata_datetime datetime NULL );
CREATE TABLE cdm_source (
			cdm_source_name TEXT NOT NULL,
			cdm_source_abbreviation TEXT NOT NULL,
			cdm_holder TEXT NOT NULL,
			source_description TEXT NULL,
			source_documentation_reference TEXT NULL,
			cdm_etl_reference TEXT NULL,
			source_release_date date NOT NULL,
			cdm_release_date date NOT NULL,
			cdm_version TEXT NULL,
			cdm_version_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			vocabulary_version TEXT NOT NULL );
CREATE TABLE concept (
			concept_id integer NOT NULL PRIMARY KEY,
			concept_name TEXT NOT NULL,
			domain_id TEXT NOT NULL REFERENCES DOMAIN (DOMAIN_ID),
			vocabulary_id TEXT NOT NULL REFERENCES VOCABULARY (VOCABULARY_ID),
			concept_class_id TEXT NOT NULL REFERENCES CONCEPT_CLASS (CONCEPT_CLASS_ID),
			standard_concept TEXT NULL,
			concept_code TEXT NOT NULL,
			valid_start_date date NOT NULL,
			valid_end_date date NOT NULL,
			invalid_reason TEXT NULL );
CREATE TABLE vocabulary (
			vocabulary_id TEXT NOT NULL PRIMARY KEY,
			vocabulary_name TEXT NOT NULL,
			vocabulary_reference TEXT NULL,
			vocabulary_version TEXT NULL,
			vocabulary_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID));
CREATE TABLE domain (
			domain_id TEXT NOT NULL PRIMARY KEY,
			domain_name TEXT NOT NULL,
			domain_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID));
CREATE TABLE concept_class (
			concept_class_id TEXT NOT NULL PRIMARY KEY,
			concept_class_name TEXT NOT NULL,
			concept_class_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID));
CREATE TABLE concept_relationship (
			concept_id_1 integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			concept_id_2 integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			relationship_id TEXT NOT NULL REFERENCES RELATIONSHIP (RELATIONSHIP_ID),
			valid_start_date date NOT NULL,
			valid_end_date date NOT NULL,
			invalid_reason TEXT NULL );
CREATE TABLE relationship (
			relationship_id TEXT NOT NULL PRIMARY KEY,
			relationship_name TEXT NOT NULL,
			is_hierarchical TEXT NOT NULL,
			defines_ancestry TEXT NOT NULL,
			reverse_relationship_id TEXT NOT NULL,
			relationship_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID));
CREATE TABLE concept_synonym (
			concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			concept_synonym_name TEXT NOT NULL,
			language_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID));
CREATE TABLE concept_ancestor (
			ancestor_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			descendant_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			min_levels_of_separation integer NOT NULL,
			max_levels_of_separation integer NOT NULL );
CREATE TABLE source_to_concept_map (
			source_code TEXT NOT NULL,
			source_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			source_vocabulary_id TEXT NOT NULL,
			source_code_description TEXT NULL,
			target_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			target_vocabulary_id TEXT NOT NULL REFERENCES VOCABULARY (VOCABULARY_ID),
			valid_start_date date NOT NULL,
			valid_end_date date NOT NULL,
			invalid_reason TEXT NULL );
CREATE TABLE drug_strength (
			drug_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			ingredient_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			amount_value REAL NULL,
			amount_unit_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			numerator_value REAL NULL,
			numerator_unit_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			denominator_value REAL NULL,
			denominator_unit_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
			box_size integer NULL,
			valid_start_date date NOT NULL,
			valid_end_date date NOT NULL,
			invalid_reason TEXT NULL );
CREATE TABLE cohort (
			cohort_definition_id integer NOT NULL PRIMARY KEY,
			subject_id integer NOT NULL,
			cohort_start_date date NOT NULL,
			cohort_end_date date NOT NULL );
CREATE TABLE cohort_definition (
			cohort_definition_id integer NOT NULL,
			cohort_definition_name TEXT NOT NULL,
			cohort_definition_description TEXT NULL,
			definition_type_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			cohort_definition_syntax TEXT NULL,
			subject_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
			cohort_initiation_date date NULL );
CREATE INDEX idx_person_id   ON person   (person_id ASC);
CREATE INDEX idx_gender  ON person  (gender_concept_id ASC);
CREATE INDEX idx_observation_period_id_1   ON observation_period   (person_id ASC);
CREATE INDEX idx_visit_person_id_1   ON visit_occurrence   (person_id ASC);
CREATE INDEX idx_visit_concept_id_1  ON visit_occurrence  (visit_concept_id ASC);
CREATE INDEX idx_visit_det_person_id_1   ON visit_detail   (person_id ASC);
CREATE INDEX idx_visit_det_concept_id_1  ON visit_detail  (visit_detail_concept_id ASC);
CREATE INDEX idx_visit_det_occ_id  ON visit_detail  (visit_occurrence_id ASC);
CREATE INDEX idx_condition_person_id_1   ON condition_occurrence   (person_id ASC);
CREATE INDEX idx_condition_concept_id_1  ON condition_occurrence  (condition_concept_id ASC);
CREATE INDEX idx_condition_visit_id_1  ON condition_occurrence  (visit_occurrence_id ASC);
CREATE INDEX idx_drug_person_id_1   ON drug_exposure   (person_id ASC);
CREATE INDEX idx_drug_concept_id_1  ON drug_exposure  (drug_concept_id ASC);
CREATE INDEX idx_drug_visit_id_1  ON drug_exposure  (visit_occurrence_id ASC);
CREATE INDEX idx_procedure_person_id_1   ON procedure_occurrence   (person_id ASC);
CREATE INDEX idx_procedure_concept_id_1  ON procedure_occurrence  (procedure_concept_id ASC);
CREATE INDEX idx_procedure_visit_id_1  ON procedure_occurrence  (visit_occurrence_id ASC);
CREATE INDEX idx_device_person_id_1   ON device_exposure   (person_id ASC);
CREATE INDEX idx_device_concept_id_1  ON device_exposure  (device_concept_id ASC);
CREATE INDEX idx_device_visit_id_1  ON device_exposure  (visit_occurrence_id ASC);
CREATE INDEX idx_measurement_person_id_1   ON measurement   (person_id ASC);
CREATE INDEX idx_measurement_concept_id_1  ON measurement  (measurement_concept_id ASC);
CREATE INDEX idx_measurement_visit_id_1  ON measurement  (visit_occurrence_id ASC);
CREATE INDEX idx_observation_person_id_1   ON observation   (person_id ASC);
CREATE INDEX idx_observation_concept_id_1  ON observation  (observation_concept_id ASC);
CREATE INDEX idx_observation_visit_id_1  ON observation  (visit_occurrence_id ASC);
CREATE INDEX idx_death_person_id_1   ON death   (person_id ASC);
CREATE INDEX idx_note_person_id_1   ON note   (person_id ASC);
CREATE INDEX idx_note_concept_id_1  ON note  (note_type_concept_id ASC);
CREATE INDEX idx_note_visit_id_1  ON note  (visit_occurrence_id ASC);
CREATE INDEX idx_note_nlp_note_id_1   ON note_nlp   (note_id ASC);
CREATE INDEX idx_note_nlp_concept_id_1  ON note_nlp  (note_nlp_concept_id ASC);
CREATE INDEX idx_specimen_person_id_1   ON specimen   (person_id ASC);
CREATE INDEX idx_specimen_concept_id_1  ON specimen  (specimen_concept_id ASC);
CREATE INDEX idx_fact_relationship_id1  ON fact_relationship  (domain_concept_id_1 ASC);
CREATE INDEX idx_fact_relationship_id2  ON fact_relationship  (domain_concept_id_2 ASC);
CREATE INDEX idx_fact_relationship_id3  ON fact_relationship  (relationship_concept_id ASC);
CREATE INDEX idx_location_id_1   ON location   (location_id ASC);
CREATE INDEX idx_care_site_id_1   ON care_site   (care_site_id ASC);
CREATE INDEX idx_provider_id_1   ON provider   (provider_id ASC);
CREATE INDEX idx_period_person_id_1   ON payer_plan_period   (person_id ASC);
CREATE INDEX idx_cost_event_id   ON cost  (cost_event_id ASC);
CREATE INDEX idx_drug_era_person_id_1   ON drug_era   (person_id ASC);
CREATE INDEX idx_drug_era_concept_id_1  ON drug_era  (drug_concept_id ASC);
CREATE INDEX idx_dose_era_person_id_1   ON dose_era   (person_id ASC);
CREATE INDEX idx_dose_era_concept_id_1  ON dose_era  (drug_concept_id ASC);
CREATE INDEX idx_condition_era_person_id_1   ON condition_era   (person_id ASC);
CREATE INDEX idx_condition_era_concept_id_1  ON condition_era  (condition_concept_id ASC);
CREATE INDEX idx_metadata_concept_id_1   ON metadata   (metadata_concept_id ASC);
CREATE INDEX idx_source_to_concept_map_3   ON source_to_concept_map   (target_concept_id ASC);
CREATE INDEX idx_source_to_concept_map_1  ON source_to_concept_map  (source_vocabulary_id ASC);
CREATE INDEX idx_source_to_concept_map_2  ON source_to_concept_map  (target_vocabulary_id ASC);
CREATE INDEX idx_source_to_concept_map_c  ON source_to_concept_map  (source_code ASC);
CREATE INDEX idx_domain_domain_id   ON domain   (domain_id ASC);
CREATE INDEX idx_vocabulary_vocabulary_id   ON vocabulary   (vocabulary_id ASC);
CREATE INDEX idx_concept_class_class_id   ON concept_class   (concept_class_id ASC);
CREATE INDEX idx_relationship_rel_id   ON relationship   (relationship_id ASC);
CREATE INDEX idx_drug_strength_id_1   ON drug_strength   (drug_concept_id ASC);
CREATE INDEX idx_drug_strength_id_2  ON drug_strength  (ingredient_concept_id ASC);
CREATE INDEX idx_concept_synonym_id   ON concept_synonym   (concept_id ASC);
CREATE INDEX idx_concept_concept_id   ON concept   (concept_id ASC);
CREATE INDEX idx_concept_code  ON concept  (concept_code ASC);
CREATE INDEX idx_concept_vocabluary_id  ON concept  (vocabulary_id ASC);
CREATE INDEX idx_concept_domain_id  ON concept  (domain_id ASC);
CREATE INDEX idx_concept_class_id  ON concept  (concept_class_id ASC);
CREATE INDEX idx_concept_ancestor_id_1   ON concept_ancestor   (ancestor_concept_id ASC);
CREATE INDEX idx_concept_ancestor_id_2  ON concept_ancestor  (descendant_concept_id ASC);
CREATE INDEX idx_concept_relationship_id_1   ON concept_relationship   (concept_id_1 ASC);
CREATE INDEX idx_concept_relationship_id_2  ON concept_relationship  (concept_id_2 ASC);
CREATE INDEX idx_concept_relationship_id_3  ON concept_relationship  (relationship_id ASC);

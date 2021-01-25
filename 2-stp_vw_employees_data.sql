--------------- run with the same order ------------------------

------------------ modify the e_mail at stp_employees to be 50 char ------------------------------------
-------------------- 1 ------------------
select deps_save_and_drop_dependencies('essf_setup', 'stp_employees');

-------------------- 2 ------------------
ALTER TABLE essf_setup.stp_employees ALTER COLUMN e_mail TYPE varchar(50) USING e_mail::varchar;

-------------------- 3 ------------------
select deps_restore_dependencies('essf_setup', 'stp_employees');

------------------ modify the e_mail at stp_vw_employees_data to read from  stp_employees instead of stp_contacts_id----------------------

-------------------- 4 ------------------
select deps_save_and_drop_dependencies('essf_setup', 'stp_vw_employees_data');

-------------------- 5 ------------------
CREATE OR REPLACE VIEW essf_setup.stp_vw_employees_data
AS SELECT e.id, e.name, e.latin_name, 
        CASE
            WHEN e.military_no IS NULL THEN '0'::character varying
            ELSE e.military_no
        END AS military_no, 
    e.official_dept_id, e.official_job_id, e.actual_dept_id, e.actual_title_id, 
    e.category_id, e.rank_id, e.education_level_id, e.gender, e.blood_group, 
    e.joining_dt, e.end_service_dt, e.stp_specialities_id, e.stp_contacts_id, 
    e.salary, e.iban, e.emp_code, e.birth_date, e.birth_date_h, e.birth_place, 
    e.first_name, e.last_name, e.marital_status, e.nationality_id, 
    e.second_name, e.social_id_issue_date, e.status_id, e.third_name, 
    e.degree_id, NULL::unknown AS med_staff_rank_id, 
    NULL::unknown AS med_staff_level_id, NULL::unknown AS med_staff_degree_id, 
    e.sequence_number, e.service_termination_date, 
    c.description AS category_description, 
    c.latin_desc AS category_latin_description, 
    r.description AS rank_description, r.latin_desc AS rank_latin_description, 
    od.name AS official_dept_name, od.latin_name AS official_dept_latin_name, 
    ad.name AS actual_dept_name, ad.latin_name AS actual_dept_latin_name, 
    t.description AS actual_title_description, t.code AS actual_title_code, 
    t.latin_desc AS actual_title_latin_description, t.basic_job_name_id, 
    t.basic_job_name_description, 
    essf_setup.pkg_nvl(t.is_dept_head, 0::numeric) AS is_manager, 
    j.description AS official_job_description, j.code AS official_job_code, 
    s.description AS speciality_description, 
    s.latin_desc AS speciality_latin_description, 
    edl.description AS education_level_description, cnt.contact_person_name, 
    cnt.fax_no, cnt.telephone_no, cnt.telephone_ext, cnt.ip_phone_ext, 
    cnt.mobile_no, cnt.web_site, e.e_mail, cnt.address, 
    rank_title.id AS rank_title_id, 
    rank_title.description AS rank_title_description, e.id_no, 
    e.hcm_employee_id, e.general_specialization, 
    countires.nationality_arabic_desc AS nationality, 
    NULL::unknown AS med_staff_level_desc, NULL::unknown AS med_staff_rank_desc, 
    NULL::unknown AS med_staff_degree_desc, NULL::unknown AS degree_description, 
    NULL::unknown AS degree_latin_description, e.is_modified, 
    e.salary_degree_id, e.salary_rank_id, e.e_mail AS e_mail2
   FROM essf_setup.stp_employees e
   LEFT JOIN essf_setup.stp_categories c ON e.category_id = c.id
   LEFT JOIN essf_setup.stp_ranks r ON e.rank_id = r.id
   LEFT JOIN essf_setup.stp_departments od ON e.official_dept_id = od.id
   LEFT JOIN essf_setup.stp_departments ad ON e.actual_dept_id = ad.id
   LEFT JOIN essf_setup.stp_vw_department_titles t ON e.actual_title_id = t.id
   LEFT JOIN essf_setup.stp_department_jobs j ON e.official_job_id = j.id
   LEFT JOIN essf_setup.stp_specialities s ON e.stp_specialities_id = s.id
   LEFT JOIN essf_setup.stp_education_levels edl ON e.education_level_id = edl.id
   LEFT JOIN essf_setup.stp_contacts cnt ON e.stp_contacts_id = cnt.id
   LEFT JOIN essf_setup.stp_rank_titles rank_title ON e.rank_title_id = rank_title.id
   LEFT JOIN essf_setup.stp_countires countires ON e.nationality_id = countires.id;


-------------------- 6 ------------------   
select deps_restore_dependencies('essf_setup', 'stp_vw_employees_data');


-------------------- 7 ------------------   
UPDATE essf_setup.stp_employees 
SET e_mail = a.e_mail 
FROM essf_setup.stp_contacts a
WHERE a.id = stp_contacts_id;

-------------------- 8 add unique constrains on e_mail to prevent e_mail repeat ------------------   
ALTER TABLE essf_setup.stp_employees ADD CONSTRAINT stp_employees_un UNIQUE (e_mail);


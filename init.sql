CREATE EXTENSION IF NOT EXISTS pgcrypto;

DROP TABLE IF EXISTS users;
CREATE TABLE users
(
    id            SERIAL PRIMARY KEY,
    username      varchar NOT NULL UNIQUE,
    password_hash varchar NOT NULL,
    first_name    varchar NOT NULL,
    last_name     varchar NOT NULL
);
INSERT INTO users (username, password_hash, first_name, last_name)
VALUES ('admin', crypt('admin', gen_salt('md5')), 'Главный', 'Админ'),
       ('user', crypt('user', gen_salt('md5')), 'Простой', 'Пользователь');


CREATE TABLE error_status
(
    id   SERIAL PRIMARY KEY,
    name varchar NOT NULL UNIQUE
);
INSERT INTO error_status (name)
VALUES ('Новая'),
       ('Открытая'),
       ('Решенная'),
       ('Закрытая');

CREATE OR REPLACE FUNCTION get_error_status_id(sname varchar) RETURNS int
    LANGUAGE SQL AS
$$
SELECT id
FROM error_status
WHERE name = sname;
$$;


CREATE TABLE error_urgency
(
    id   SERIAL PRIMARY KEY,
    name varchar NOT NULL UNIQUE
);
INSERT INTO error_urgency (name)
VALUES ('Очень срочно'),
       ('Срочно'),
       ('Не срочно'),
       ('Совсем не срочно');


CREATE TABLE error_criticality
(
    id   SERIAL PRIMARY KEY,
    name varchar NOT NULL UNIQUE
);
INSERT INTO error_criticality (name)
VALUES ('Авария'),
       ('Критичная'),
       ('Некритичная'),
       ('Запрос на изменение');

CREATE TABLE errors
(
    id                   SERIAL PRIMARY KEY,
    date                 TIMESTAMP NOT NULL,
    short_description    varchar   NOT NULL,
    detailed_description varchar   NOT NULL,
    user_id              int       NOT NULL REFERENCES users,
    status_id            int       NOT NULL DEFAULT get_error_status_id('Новая') REFERENCES error_status,
    urgency_id           int       NOT NULL REFERENCES error_urgency,
    criticality_id       int       NOT NULL REFERENCES error_criticality
);

CREATE TABLE error_history
(
    id           SERIAL PRIMARY KEY,
    error_id     int                         NOT NULL REFERENCES errors ON DELETE CASCADE,
    date         TIMESTAMP                   NOT NULL,
    new_status   int REFERENCES error_status NOT NULL,
    edit_comment varchar                     NOT NULL,
    user_id      int REFERENCES users        NOT NULL
);

CREATE TABLE status_change_rules
(
    from_id int NOT NULL REFERENCES error_status ON DELETE CASCADE,
    to_id   int NOT NULL REFERENCES error_status ON DELETE CASCADE,
    PRIMARY KEY (from_id, to_id)
);
INSERT INTO status_change_rules (from_id, to_id)
VALUES (get_error_status_id('Новая'), get_error_status_id('Открытая')),
       (get_error_status_id('Новая'), get_error_status_id('Решенная')),
       (get_error_status_id('Новая'), get_error_status_id('Закрытая')),
       (get_error_status_id('Открытая'), get_error_status_id('Открытая')),
       (get_error_status_id('Открытая'), get_error_status_id('Решенная')),
       (get_error_status_id('Открытая'), get_error_status_id('Закрытая')),
       (get_error_status_id('Решенная'), get_error_status_id('Открытая')),
       (get_error_status_id('Решенная'), get_error_status_id('Решенная')),
       (get_error_status_id('Решенная'), get_error_status_id('Закрытая')),
       (get_error_status_id('Закрытая'), get_error_status_id('Закрытая'));

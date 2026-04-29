package main

import (
	"log"
	"time"

	"github.com/robfig/cron/v3"
)

// ================= START CRON =================

func StartAttendanceCron() *cron.Cron {
	log.Println("[attendance_cron] initializing...")

	// Backfill past missing absents on startup
	if err := backfillAbsent(); err != nil {
		log.Printf("[attendance_cron] backfill error: %v", err)
	}

	c := cron.New()

	// 8:00 AM (Mon–Fri)
	_, err := c.AddFunc("0 8 * * 1-5", func() {
		log.Println("[attendance_cron] running 8AM auto-absent...")
		if err := autoMarkAbsent(time.Now()); err != nil {
			log.Printf("[attendance_cron] 8AM error: %v", err)
		}
	})
	if err != nil {
		log.Println("Cron error:", err)
	}

	// 5:00 PM (Mon–Fri)
	_, err = c.AddFunc("0 17 * * 1-5", func() {
		log.Println("[attendance_cron] running 5PM auto-absent...")
		if err := autoMarkAbsent(time.Now()); err != nil {
			log.Printf("[attendance_cron] 5PM error: %v", err)
		}
	})
	if err != nil {
		log.Println("Cron error:", err)
	}

	c.Start()
	log.Println("[attendance_cron] started successfully")

	return c
}

func autoMarkAbsent(today time.Time) error {
	dateStr := today.Format("2006-01-02")

	// Skip weekends
	if today.Weekday() == time.Saturday || today.Weekday() == time.Sunday {
		log.Println("[attendance_cron] weekend skipped:", dateStr)
		return nil
	}

	// Check holiday
	var isHoliday bool
	err := db.QueryRow(`
		SELECT EXISTS(SELECT 1 FROM holidays WHERE holiday_date = $1)
	`, dateStr).Scan(&isHoliday)
	if err != nil {
		return err
	}
	if isHoliday {
		log.Println("[attendance_cron] holiday skipped:", dateStr)
		return nil
	}

	_, err = db.Exec(`
		UPDATE time_logs
		SET status = 'absent',
		    hours_rendered = 0
		WHERE log_date = $1::date
		AND time_in IS NOT NULL
		AND time_out IS NULL
		AND status != 'absent'
	`, dateStr)

	if err != nil {
		return err
	}

	log.Println("[attendance_cron] absents inserted for:", dateStr)
	return nil
}

func backfillAbsent() error {
	log.Println("[attendance_cron] running backfill...")

	today := time.Now().Truncate(24 * time.Hour)

	rows, err := db.Query(`
		SELECT u.id, MIN(tl.log_date) AS first_log
		FROM users u
		JOIN time_logs tl ON tl.user_id = u.id
		WHERE u.role = 'intern'
		  AND tl.time_in IS NOT NULL
		GROUP BY u.id
	`)
	if err != nil {
		return err
	}
	defer rows.Close()

	type intern struct {
		userID   string
		firstLog time.Time
	}

	var interns []intern

	for rows.Next() {
		var i intern
		if err := rows.Scan(&i.userID, &i.firstLog); err != nil {
			continue
		}
		interns = append(interns, i)
	}

	for _, i := range interns {
		cursor := i.firstLog.Truncate(24 * time.Hour)

		for cursor.Before(today) {

			// Skip weekends
			if cursor.Weekday() == time.Saturday || cursor.Weekday() == time.Sunday {
				cursor = cursor.Add(24 * time.Hour)
				continue
			}

			dateStr := cursor.Format("2006-01-02")

			// Skip holidays
			var isHoliday bool
			db.QueryRow(`
				SELECT EXISTS(SELECT 1 FROM holidays WHERE holiday_date = $1)
			`, dateStr).Scan(&isHoliday)

			if isHoliday {
				cursor = cursor.Add(24 * time.Hour)
				continue
			}

			// Insert if missing
			db.Exec(`
				INSERT INTO time_logs (user_id, log_date, status)
				SELECT $1, $2::date, 'absent'
				WHERE NOT EXISTS (
					SELECT 1 FROM time_logs
					WHERE user_id = $1
					AND log_date = $2::date
				)
			`, i.userID, dateStr)

			cursor = cursor.Add(24 * time.Hour)
		}
	}

	log.Println("[attendance_cron] backfill complete")
	return nil
}

func ensureAbsentsForDate(date time.Time) error {
	dateStr := date.Format("2006-01-02")

	// Skip weekends
	if date.Weekday() == time.Saturday || date.Weekday() == time.Sunday {
		return nil
	}

	// Skip holidays
	var isHoliday bool
	err := db.QueryRow(`
		SELECT EXISTS(SELECT 1 FROM holidays WHERE holiday_date = $1)
	`, dateStr).Scan(&isHoliday)
	if err != nil {
		return err
	}
	if isHoliday {
		return nil
	}

	// Insert missing absents
	_, err = db.Exec(`
		INSERT INTO time_logs (user_id, log_date, status)
		SELECT u.id, $1::date, 'absent'
		FROM users u
		WHERE u.role = 'intern'
		AND NOT EXISTS (
			SELECT 1 FROM time_logs tl
			WHERE tl.user_id = u.id
			AND tl.log_date = $1::date
		)
	`, dateStr)

	return err
}
package main

import (
	"encoding/json"
	"net/http"
	"strings"
)

// Struct for chart data
type SchoolStat struct {
	Year   int    `json:"year"`
	School string `json:"school"`
	Count  int    `json:"count"`
}

func normalizeSchool(school string) string {
    s := strings.ToLower(strings.TrimSpace(school))
    switch {
    case s == "plsp" || strings.Contains(s, "pamantasan ng lungsod ng san pablo"):
        return "PLSP"
    case s == "cmdi" || strings.Contains(s, "card mri development institute"):
        return "CMDI"
    case s == "lspu" || strings.Contains(s, "laguna state polytechnic university"):
        return "LSPU"
    default:
        return "OTHERS"
    }
}

// Handler
func SchoolStats(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodGet {
        jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
        return
    }

    rows, err := db.Query(`
        SELECT 
            EXTRACT(YEAR FROM created_at)::int as year,
            school, 
            COUNT(*) as count
        FROM users
        WHERE role = 'intern'
        GROUP BY year, school
        ORDER BY year, school
    `)
    if err != nil {
        jsonError(w, "Error fetching school stats", http.StatusInternalServerError)
        return
    }
    defer rows.Close()

    // year -> school -> count
    type yearKey struct {
        year   int
        school string
    }
    aggregated := make(map[yearKey]int)
    var years []int
    yearSeen := make(map[int]bool)

    for rows.Next() {
        var stat SchoolStat
        if err := rows.Scan(&stat.Year, &stat.School, &stat.Count); err != nil {
            continue
        }
        normalized := normalizeSchool(stat.School)
        key := yearKey{stat.Year, normalized}
        aggregated[key] += stat.Count
        if !yearSeen[stat.Year] {
            years = append(years, stat.Year)
            yearSeen[stat.Year] = true
        }
    }

    var stats []SchoolStat
    for _, y := range years {
        for _, school := range []string{"PLSP", "CMDI", "LSPU", "OTHERS"} {
            count := aggregated[yearKey{y, school}]
            if count > 0 {
                stats = append(stats, SchoolStat{Year: y, School: school, Count: count})
            }
        }
    }

    if stats == nil {
        stats = []SchoolStat{}
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(stats)
}
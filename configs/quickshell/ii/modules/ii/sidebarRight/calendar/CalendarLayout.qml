// CalendarUtils.qml
pragma Singleton
import QtQuick

QtObject {
    readonly property var weekDays: [
        { day: "Mo", today: 0 },
        { day: "Tu", today: 0 },
        { day: "We", today: 0 },
        { day: "Th", today: 0 },
        { day: "Fr", today: 0 },
        { day: "Sa", today: 0 },
        { day: "Su", today: 0 }
    ]

    function checkLeapYear(year) {
        return (
            year % 400 === 0 ||
            (year % 4 === 0 && year % 100 !== 0)
        )
    }

    function getMonthDays(month, year) {
        const leapYear = checkLeapYear(year)

        if ((month <= 7 && month % 2 === 1)
                || (month >= 8 && month % 2 === 0))
            return 31

        if (month === 2 && leapYear)
            return 29

        if (month === 2 && !leapYear)
            return 28

        return 30
    }

    function getNextMonthDays(month, year) {
        const leapYear = checkLeapYear(year)

        if (month === 1 && leapYear)
            return 29

        if (month === 1 && !leapYear)
            return 28

        if (month === 12)
            return 31

        if ((month <= 7 && month % 2 === 1)
                || (month >= 8 && month % 2 === 0))
            return 30

        return 31
    }

    function getPrevMonthDays(month, year) {
        const leapYear = checkLeapYear(year)

        if (month === 3 && leapYear)
            return 29

        if (month === 3 && !leapYear)
            return 28

        if (month === 1)
            return 31

        if ((month <= 7 && month % 2 === 1)
                || (month >= 8 && month % 2 === 0))
            return 30

        return 31
    }

    function getDateInXMonthsTime(x) {
        let currentDate = new Date()

        if (x === 0)
            return currentDate

        let targetMonth = currentDate.getMonth() + x
        let targetYear = currentDate.getFullYear()

        targetYear += Math.floor(targetMonth / 12)
        targetMonth = (targetMonth % 12 + 12) % 12

        return new Date(targetYear, targetMonth, 1)
    }

    function getCalendarLayout(dateObject, highlight) {
        if (!dateObject)
            dateObject = new Date()

        const weekday = (dateObject.getDay() + 6) % 7
        const day = dateObject.getDate()
        const month = dateObject.getMonth() + 1
        const year = dateObject.getFullYear()

        const weekdayOfMonthFirst =
                (weekday + 35 - (day - 1)) % 7

        const daysInMonth = getMonthDays(month, year)
        const daysInNextMonth = getNextMonthDays(month, year)
        const daysInPrevMonth = getPrevMonthDays(month, year)

        let monthDiff = (weekdayOfMonthFirst === 0 ? 0 : -1)

        let toFill
        let dim

        if (weekdayOfMonthFirst === 0) {
            toFill = 1
            dim = daysInMonth
        } else {
            toFill = daysInPrevMonth - (weekdayOfMonthFirst - 1)
            dim = daysInPrevMonth
        }

        let calendar = []

        for (let i = 0; i < 6; ++i) {
            calendar[i] = []

            for (let j = 0; j < 7; ++j) {

                calendar[i][j] = {
                    day: toFill,
                    today: (
                        (toFill === day && monthDiff === 0 && highlight)
                        ? 1
                        : (monthDiff === 0 ? 0 : -1)
                    )
                }

                toFill++

                if (toFill > dim) {
                    monthDiff++

                    if (monthDiff === 0)
                        dim = daysInMonth
                    else if (monthDiff === 1)
                        dim = daysInNextMonth

                    toFill = 1
                }
            }
        }

        return calendar
    }
}
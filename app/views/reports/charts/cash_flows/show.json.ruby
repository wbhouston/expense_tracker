{
  data: {
    datasets: [
      @view_object.revenues_by_month,
      @view_object.expenses_by_month,
    ],
  },
  options: {
    plugins: {
      zoom: {
        pan: {
          enabled: true,
          mode: 'x',
        },
        zoom: {
          wheel: {
            enabled: true,
          },
          pinch: {
            enabled: true
          },
          mode: 'x',
        }
      }
    },
    scales: {
      x: {
        min: 12.months.ago.beginning_of_month,
        type: :time,
        ticks: {
          source: 'data',
        },
        time: {
          tooltipFormat: 'yyyy DD'
        },
        title: {
          display: true,
          text: 'Date',
        }
      },
    },
  },
  type: :line,
}.to_json
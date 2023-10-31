{
  data: {
    datasets: @view_object.balances_by_month,
  },
  options: {
    interaction: {
      enabled: true,
      intersect: false,
      mode: 'index',
    },
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
          tooltipFormat: 'LLL yyyy'
        },
        title: {
          display: true,
          text: 'Date',
        }
      },
      y: {
        min: 0,
      },
    },
  },
  type: :line,
}.to_json
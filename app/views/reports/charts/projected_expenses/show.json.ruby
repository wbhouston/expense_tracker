{
  data: {
    datasets: [
      @view_object.projected_monthly_expenses.merge(yAxisID: :y),
      @view_object.projected_yearly_expenses.merge(yAxisID: :y),
      @view_object.projected_total_expenses.merge(yAxisID: :y1),
    ],
  },
  options: {
    interaction: {
      enabled: true,
      intersect: false,
      mode: 'index',
    },
    plugins: {
      subtitle: {
        display: true,
        text: 'Sum of and projected expenses for the next 6 months',
        position: :bottom,
      },
    },
    scales: {
      x: {
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
        type: 'linear',
        display: true,
        position: :right,
      },
      y1: {
        type: 'linear',
        display: true,
        position: :left,
        grid: {
          drawOnChartArea: false,
        },
      }
    },
  },
  type: :line,
}.to_json
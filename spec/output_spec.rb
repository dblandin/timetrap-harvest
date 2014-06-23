require_relative '../lib/timetrap_harvest/output'

describe 'HarvestOutput' do
  it 'prints out submitted entries' do
    results = { submitted: [{ notes: 'doing some work @code' }] }

    output = TimetrapHarvest::Output.new(results)

    expect(output.generate).to include('Submitted: 1')
    expect(output.generate).to include('Submitted: doing some work @code')
  end

  it 'prints out failed submissions' do
    results = { failed: [{
      note: 'doing some work @unknown',
      error: 'Missing task alias config'
    }] }

    output = TimetrapHarvest::Output.new(results)

    expect(output.generate).to include('Failed: 1')
    expect(output.generate).to include(
      "Failed (Missing task alias config): doing some work @unknown"
    )
  end
end

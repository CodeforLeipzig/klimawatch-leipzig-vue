<template>
    <h2>Chart</h2>
    <div>
        <ul v-if="years && years.length">
            <li v-for="year in years">
                <p>{{year}}</p>
            </li>
        </ul>

        <select v-model="selectedSector">
            <option v-for="sector in sectors" :value="sector">{{sector}}</option>
        </select>
        <br />
        <svg></svg>

        <ul v-if="errorMessages && errorMessages.length">
            <li v-for="error of errorMessages">
                {{error}}
            </li>
        </ul>
    </div>
</template>

<script lang="ts">
import axios from 'axios';
import { scaleBand} from 'd3';
import * as d3 from 'd3';

declare interface Emission {
    year: Number,
    value: Number
}

declare interface EmissionsBackendValues {
    "Jahr": Number,
    "Wert": Number
}

declare interface ErrorWithMessage {
    message: string
}

export default {
    name: 'Chart',
    data() {
        return {
            selectedSector: String,
            years: Array<Number>,
            sectors: Array<String>,
            emissionsBackend: Array<EmissionsBackendValues>,    
            emissions: Array<Emission>,        
            errorMessages: Array<String>
        }
    },
    computed: {
        filteredData() {
            return [{
                x: "2017",
                y: 500,
            },{
                x: "2018",
                y: 700,
            }]
        },
        maxValue() {
            return 700;
        },  
    },
    methods: {
        setError(errors: Array<ErrorWithMessage>) {
            this.errorMessages.apply(errors);
        },
        renderChart() {
            const height = 300
            const roundedHeight = Math.ceil((height + 1)/10) * 10
            const width = 800
            const yearStrs = scaleBand([2017, 2018]) // TODO: this.years instead
            // set the ranges
            const xScale = d3
                .scaleBand()
                .domain(yearStrs.domain())
                .range([0, width])
                .padding(0.2)
            const yScale = d3
                .scaleLinear()
                .domain([0, this.maxValue])
                .range([roundedHeight, 10])
            const container = d3.select('svg')
                .classed('chart-container', true)
                .style('height', `${roundedHeight}px`)
                .style('width', `${width}px`)
            // eslint-disable-next-line no-unused-vars
            const bar = container
                .selectAll('.bar')
                .data(this.filteredData)
                .enter()
                .append('rect')
                .classed('bar', true)
                .attr('width', xScale.bandwidth())
                .attr('height', data => roundedHeight - yScale(data.y))
                .attr('x', data => data.x)
                .attr('y', data => yScale(data.y))
            // add the x Axis
            container.append("g")
                .attr('transform', "translate(0," + roundedHeight + ")")
                .call(d3.axisBottom(xScale))
                .selectAll('text')
                .attr('transform', "translate(-15, 15) rotate(-45)");
            // add the y Axis
            container.append("g")
                .call(d3.axisLeft(yScale));
        }
    },    
    // Fetches posts when the component is created.
    created() {
        axios.get(`http://localhost:8080/emissions/years`)
        .then(response => {
            this.years = response.data
        })
        .catch((e: Error) => {
            this.errorMessages.apply(e.message)
        })
        axios.get(`http://localhost:8080/emissions/sectors`)
        .then(response => {
            this.sectors = response.data
        })
        .catch((e: Error) => {
            this.errorMessages.apply(e.message)
        })
        axios.get(`http://localhost:8080/emissions/greenhouse-gases?sector=Verkehr`)
        .then(response => {
            this.emissionsBackend = response.data["Werte"]
        })
        .catch((e: Error) => {
            this.errorMessages.apply(e.message)
        })
    },
    mounted() {
        this.renderChart()
    },
    updated() {
        this.renderChart()
    },
    beforeUpdate() {
        var svg = d3.select("svg")
        svg
        .selectAll('*')
        .remove()
    },
}
</script>

<style>
  .chart-container {
    border: 1px solid navy;
    margin-left: auto;
    margin-right: auto;
    overflow: visible;
  }
  .bar { 
    fill: rgb(255, 0, 212);
  }
  text {
    fill: navy;
    font-size: smaller;
  }
  path.domain {
    stroke: transparent;
  }
  select {
    margin-bottom: 20px;
  }
</style>
<template>
    <h2>Chart</h2>
    <div>
        <ul v-if="years && years.length">
            <li v-for="year in years">
                <p>{{year}}</p>
            </li>
        </ul>

        <ul v-if="errorMessages && errorMessages.length">
            <li v-for="error of errorMessages">
                {{error}}
            </li>
        </ul>
    </div>
</template>

<script lang="ts">
import axios from 'axios';

declare interface Emission {
    year: Number,
    sector: string
    value: Number
  }

declare interface ErrorWithMessage {
    message: string
}

export default {
    data() {
        return {
            years: Array<Number>,
            sectors: Array<String>,
            emissions: Array<Emission>,        
            errorMessages: Array<String>
        }
    },
    methods: {
        setError(errors: Array<ErrorWithMessage>) {
            this.errorMessages.apply(errors);
        }
    },    
    // Fetches posts when the component is created.
    created() {
        axios.get(`http://localhost:8080/emissions/years`)
        .then(response => {
            console.log("data:" + response.data)
            this.years = response.data
        })
        .catch((e: Error) => {
            this.errorMessages.apply(e.message)
        })
    }
}
</script>